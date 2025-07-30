//
//  RouteManager.swift
//  Sidebar
//
//  Created by MINJEONG on 7/18/25.
//

import CoreLocation
import FirebaseFirestore
import Foundation
import MapKit

// MARK: - 섹션 관리 매니저
/// 모든 플랜 섹션 및 하위 장소 버튼 동작처리를 관리하고, PlanA/B섹션을 기본 제공합니다.
class PlanManager: ObservableObject {
    @Published var selectedPlanID: String? = nil
    @Published var plans: [Plan] = []
    @Published var mapDetails: [MapDetail] = []// 위도 경도
    @Published var annotations: [POIAnnotation] = [] // 장소 이름, 카테고리, 지도 검색 결과 기반
    @Published var selectedForDeletionPlaceIDs: [String] = []
    @Published var selectedPlanIDsForEdit: [String] = []
    
    private var locationManager: LocationManager?
    private let planRepository: PlanRepositoryProtocol = PlanRepository()
    private let mapDetailRepository: MapDetailRepositoryProtocol = MapDetailRepository()
    
    // MARK: - 초기화 및 구성
    /// PlanManager 내부에 locationManager 객체를 주입 해주는 역할
    func configure(with locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    @MainActor
    func loadPlans(for projectID: String) async {
        do {
            let fetched = try await planRepository.loadPlans(projectID: projectID)
            self.plans = fetched
            self.mapDetails = []
            self.annotations = []
            
            for plan in fetched {
                let details = try await mapDetailRepository.loadMapDetailsFromPlan(
                    projectID: projectID,
                    containerID: plan.id ?? ""
                )
                self.mapDetails.append(contentsOf: details)
                
                for detail in details {
                    convertMapDetailToPOIAnnotation(detail) { [weak self] annotation in
                        guard let annotation = annotation else { return }
                        DispatchQueue.main.async {
                            self?.annotations.append(annotation)
                        }
                    }
                }
            }
        } catch {
            print("PlanManager Error - Failed to load plans: \(error)")
        }
    }
    
    // MARK: - 선택 상태 관리
    /// [장소 단일선택 모드]Plan이 눌리지 않은 경우 단일로 선택된 장소
    @Published var soloSelectedPlaceID: String? = nil
    /// [Plan 섹션 선택]현재 Plan 선택상태에서 선택된 장소 1~2개
    @Published var selectedPlaceIDs: [String] = []
    
    // MARK: - 지도에서 마커 및 경로 제거
    ///마커/경로 제거
    private func clearMapView() {
        guard let mapView = locationManager?.mapView else { return }
        DispatchQueue.main.async {
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
        }
    }
    
    // MARK: - 선택 상태 초기화
    /// 선택 상태 초기화 + 마커/경로 제거
    func resetSelections() {
        selectedPlaceIDs = []
        soloSelectedPlaceID = nil
        
        clearMapView()
    }
    
    // MARK: - 핀마커 어노테이션 추가
    private func addAnnotation(for detail: MapDetail, to mapView: MKMapView) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = detail.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func mapDetails(for planID: String) -> [MapDetail] {
        mapDetails.filter { $0.containerID == planID }
    }
    
    // MARK: - Plan버튼 선택(전체경로 표시함수)
    /// 섹션 선택 시 기존 상태 초기화 및 전체 경로 그리기
    func selectPlan(_ planID: String?) {
        selectedPlanID = planID
        
        resetSelections()
        
        guard let locationManager = locationManager else { return }
        
        guard let planID = planID,
              plans.first(where: { $0.id == planID }) != nil
        else { return }
        
        guard let mapView = locationManager.mapView else { return }
        
        let details = mapDetails(for: planID)
        let coordinates = details.map { $0.coordinate }
        
        // 메인 스레드에서 UI 업데이트 보장
        DispatchQueue.main.async {
            //선택한 Plan 섹션에 포함된 모든 장소를 지도에 마커로 표시
            for detail in details {
                self.addAnnotation(for: detail, to: mapView)
            }
            
            //전체경로 표시
            if coordinates.count >= 2 {
                for i in 0..<coordinates.count - 1 {
                    locationManager.showRoute(
                        from: coordinates[i],
                        to: coordinates[i + 1],
                        on: mapView
                    ) { _ in }
                }
            }
            
            locationManager.zoomToRegion(containing: coordinates)
        }
    }
    
    // MARK: - [Plan 섹션선택] 장소 선택 처리 (toggle): 내부로직1,2,3존재
    /// [Plan 섹션선택]에서 장소 두 개까지 선택 (경로 표시), Plan 비활성 상태에서는 [단일 장소선택 모드]
    /// 다른 섹션의 장소를 선택하면 선택 상태를 초기화합니다.
    func toggleSelectedPlace(_ placeID: String) {
        guard locationManager != nil else { return }
        
        if let planID = selectedPlanID {
            let details = mapDetails(for: planID)
            //현재 선택된 Plan 섹션에 속하지 않은 장소를 선택한 경우
            guard details.contains(where: { $0.id == placeID }) else {
                selectPlaceOutsidePlan(placeID)
                return
            }
            // 내부 로직2: [Plan섹션 선택] 선택된 Plan 내에서 장소 선택할때
            selectPlaceInPlan(placeID, in: details)
        } else {
            //Plan이 비활성화된 경우
            //내부 로직3: [장소 단일선택 모드] 장소 단독 선택 처리
            selectPlaceSolo(placeID)
        }
    }
    
    // MARK: - 내부 로직1: 선택된 Plan과 다른 섹션의 장소 선택
    /// 기존 선택 상태와 선택된 섹션을 초기화하고, 해당 장소만 단독으로 지도에 표시합니다.
    private func selectPlaceOutsidePlan(_ placeID: String) {
        guard let locationManager = locationManager,
              let mapView = locationManager.mapView else { return }
        
        resetSelections()
        
        soloSelectedPlaceID = placeID
        selectedPlanID = nil
        
        clearMapView()
        
        if let place = mapDetails.first(where: { $0.id == placeID }) {
            DispatchQueue.main.async {
                self.addAnnotation(for: place, to: mapView)
                locationManager.zoomToRegion(containing: [place.coordinate])
            }
        }
    }
    
    // MARK: - 내부 로직2: 선택된 Plan 내에서 장소 선택할때
    /// Plan 버튼이 활성화된 상태에서 섹션 내 장소를 선택할 때 호출되는 함수입니다.
    /// 최대 2개의 장소까지 선택 가능하며, 선택된 장소 수에 따라 지도에 마커 또는 경로를 표시합니다.
    private func selectPlaceInPlan(_ placeID: String, in details: [MapDetail]) {
        guard let locationManager = locationManager,
              let mapView = locationManager.mapView else { return }
        
        // 경우1. 이미 선택된 장소를 다시 누른 경우: 선택 해제
        if selectedPlaceIDs.contains(placeID) {
            selectedPlaceIDs.removeAll { $0 == placeID }
        } else {
            // 경우2. 장소 두 개 이상 선택되어 있으면 새로운 하나로 교체, 아니면 추가
            if selectedPlaceIDs.count >= 2 {
                selectedPlaceIDs = [placeID]
            } else {
                selectedPlaceIDs.append(placeID)
            }
        }
        // [단일 장소선택모드] 해제
        soloSelectedPlaceID = nil
        
        clearMapView()
        
        // 현재 선택된 장소 목록 추출
        let selectedDetails = details.filter {
            selectedPlaceIDs.contains($0.id ?? "")
        }
        
        DispatchQueue.main.async {
            if selectedDetails.count == 1 {
                self.addAnnotation(for: selectedDetails[0], to: mapView)
                locationManager.zoomToRegion(containing: [
                    selectedDetails[0].coordinate
                ])
            } else if selectedDetails.count == 2 {
                let start = selectedDetails[0].coordinate
                let end = selectedDetails[1].coordinate
                locationManager.showRoute(from: start, to: end, on: mapView) { _ in }
                self.addAnnotation(for: selectedDetails[0], to: mapView)
                self.addAnnotation(for: selectedDetails[1], to: mapView)
                locationManager.zoomToRegion(containing: [start, end])
            }
            //선택이 전부 해제된 경우 → 전체 Plan 경로 다시 표시
            if selectedDetails.isEmpty {
                for detail in details {
                    self.addAnnotation(for: detail, to: mapView)
                }
                
                let coordinates = details.map { $0.coordinate }
                if coordinates.count >= 2 {
                    for i in 0..<coordinates.count - 1 {
                        locationManager.showRoute(
                            from: coordinates[i],
                            to: coordinates[i + 1],
                            on: mapView
                        ) { _ in }
                    }
                }
                locationManager.zoomToRegion(containing: coordinates)
            }
        }
    }
    
    // MARK: - 내부 로직3: [Plan 비활성 상태] 장소 단독 선택 처리
    private func selectPlaceSolo(_ placeID: String) {
        guard let locationManager = locationManager,
              let mapView = locationManager.mapView else { return }
        
        if soloSelectedPlaceID == placeID {
            resetSelections()
        } else {
            resetSelections()
            soloSelectedPlaceID = placeID
            
            clearMapView()
            
            if let place = mapDetails.first(where: { $0.id == placeID }) {
                DispatchQueue.main.async {
                    self.addAnnotation(for: place, to: mapView)
                    locationManager.zoomToRegion(containing: [place.coordinate])
                }
            }
        }
    }
    
    func convertMapDetailToPOIAnnotation(_ mapDetail: MapDetail, completion: @escaping (POIAnnotation?) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = mapDetail.name
        request.region = MKCoordinateRegion(center: mapDetail.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let item = response?.mapItems.first else {
                let fallback = POIAnnotation(
                    mapItem: MKMapItem(placemark: MKPlacemark(coordinate: mapDetail.coordinate)),
                    keyword: "location"
                )
                completion(fallback)
                return
            }
            
            let rawKeyword = item.pointOfInterestCategory?.rawValue ?? "location"
            
            // keyword 정제 로직 추가
            let keyword: String
            let lowered = rawKeyword.lowercased()
            
            if lowered.contains("restaurant") || lowered.contains("food") {
                keyword = "restaurant"
            } else if lowered.contains("cafe") || lowered.contains("coffee") || lowered.contains("bakery") {
                keyword = "cafe"
            } else {
                keyword = "location"
            }
            
            let annotation = POIAnnotation(mapItem: item, keyword: keyword)
            completion(annotation)
        }
    }
    
    func togglePlaceForDeletion(_ placeID: String) {
        if selectedForDeletionPlaceIDs.contains(placeID) {
            selectedForDeletionPlaceIDs.removeAll { $0 == placeID }
        } else {
            selectedForDeletionPlaceIDs.append(placeID)
        }
    }
    
    func toggleEditSelection(for planID: String) {
        if selectedPlanIDsForEdit.contains(planID) {
            selectedPlanIDsForEdit.removeAll { $0 == planID }
        } else {
            selectedPlanIDsForEdit.append(planID)
        }
    }
    
    // MARK: - 삭제 관련 함수들
    @MainActor
    func deletePlanSection(projectID: String, planID: String) async {
        do {
            try await planRepository.deletePlan(projectID: projectID, planID: planID)
            
            self.plans.removeAll { $0.id == planID }
            self.mapDetails.removeAll { $0.containerID == planID }
            
        } catch {
            print("Plan 섹션 삭제 실패: \(error)")
        }
    }

    @MainActor
    func deletePlace(projectID: String, placeID: String) async {
        guard let mapDetail = mapDetails.first(where: { $0.id == placeID }) else {
            return
        }
        
        let containerID = mapDetail.containerID
        
        do {
            try await mapDetailRepository.deleteMapDetail(
                projectID: projectID,
                containerID: containerID,
                mapDetailID: placeID
            )
            self.mapDetails.removeAll { $0.id == placeID }
            
        } catch {
            print("장소 삭제 실패: \(error)")
        }
    }
    
    @MainActor
    func createNewPlan(projectID: String) async {
        do {
            try await planRepository.createPlan(projectID: projectID)
            await loadPlans(for: projectID)
        } catch {
            print("❌ Plan 생성 실패: \(error)")
        }
    }
}


