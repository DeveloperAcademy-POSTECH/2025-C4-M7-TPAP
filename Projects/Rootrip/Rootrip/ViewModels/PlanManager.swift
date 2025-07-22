//
//  RouteManager.swift
//  Sidebar
//
//  Created by MINJEONG on 7/18/25.
//

import Foundation
import CoreLocation
import MapKit

// MARK: - 섹션 관리 매니저
/// 모든 플랜 섹션 및 하위 장ㅅ버튼 동작처리를 관리하고, PlanA/B섹션을 기본 제공합니다.
class PlanManager: ObservableObject {
    @Published var selectedPlanID: String? = nil
    //TODO: -샘플 훗날제거
    @Published var plans: [Plan] = samplePlans
    @Published var mapDetails: [MapDetail] = sampleMapDetails
    
    private var routeManager: RouteManager?
    
    // MARK: - 초기화 및 구성
    /// PlanManager 내부에 routeManager 객체를 주입 해주는 역할
    func configure(with routeManager: RouteManager) {
        self.routeManager = routeManager
    }
    
    // MARK: - 선택 상태 관리
    /// [장소 단일선택 모드]Plan이 눌리지 않은 경우 단일로 선택된 장소
    @Published var soloSelectedPlaceID: String? = nil
    /// [Plan 섹션 선택]현재 Plan 선택상태에서 선택된 장소 1~2개
    @Published var selectedPlaceIDs: [String] = []
    
    // MARK: - 지도에서 마커 및 경로 제거
    ///마커/경로 제거
    private func clearMapView() {
        guard let mapView = routeManager?.mapView else { return }
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
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
        annotation.title = detail.name
        mapView.addAnnotation(annotation)
    }
    
    func mapDetails(for planID: String) -> [MapDetail] {
        mapDetails.filter { $0.planID == planID }
    }
    
    
    // MARK: - Plan버튼 선택(전체경로 표시함수)
    /// 섹션 선택 시 기존 상태 초기화 및 전체 경로 그리기
    func selectPlan(_ planID: String?) {
        selectedPlanID = planID
        
        resetSelections()
        
        guard let routeManager = routeManager else { return }
        guard let planID = planID,
              let _ = plans.first(where: { $0.id == planID }) else { return }
        
        let mapView = routeManager.mapView
        let details = mapDetails(for: planID)
        let coordinates = details.map { $0.coordinate }
        
        //선택한 Plan 섹션에 포함된 모든 장소를 지도에 마커로 표시
        for detail in details {
            addAnnotation(for: detail, to: mapView)
        }
        
        
        //전체경로 표시
        if coordinates.count >= 2 {
            for i in 0..<coordinates.count - 1 {
                routeManager.showRoute(from: coordinates[i], to: coordinates[i + 1], on: mapView) { _ in }
            }
        }
        routeManager.zoomToRegion(containing: coordinates)
    }
    
    // MARK: - [Plan 섹션선택] 장소 선택 처리 (toggle): 내부로직1,2,3존재
    /// [Plan 섹션선택]에서 장소 두 개까지 선택 (경로 표시), Plan 비활성 상태에서는 [단일 장소선택 모드]
    /// 다른 섹션의 장소를 선택하면 선택 상태를 초기화합니다.
    func toggleSelectedPlace(_ placeID: String) {
        guard routeManager != nil else { return }
        
        if let planID = selectedPlanID {
            let details = mapDetails(for: planID)
            //현재 선택된 Plan 섹션에 속하지 않은 장소를 선택한 경우
            guard details.contains(where: { $0.id == placeID }) else {
                selectPlaceOutsidePlan(placeID)
                return
            }
            // 내부 로직2: [Plan섹션 선택] 선택된 Plan 내에서 장소 선택할때
            selectPlaceInPlan(placeID, in: details)
        }
        else {
            //Plan이 비활성화된 경우
            //내부 로직3: [장소 단일선택 모드] 장소 단독 선택 처리
            selectPlaceSolo(placeID)
        }
    }
    
    // MARK: - 내부 로직1: 선택된 Plan과 다른 섹션의 장소 선택
    /// 기존 선택 상태와 선택된 섹션을 초기화하고, 해당 장소만 단독으로 지도에 표시합니다.
    private func selectPlaceOutsidePlan(_ placeID: String) {
        guard let routeManager = routeManager else { return }
        let mapView = routeManager.mapView
        
        resetSelections()
        
        soloSelectedPlaceID = placeID
        selectedPlanID = nil
        
        clearMapView()
        
        if let place = mapDetails.first(where: { $0.id == placeID })  {
            addAnnotation(for: place, to: mapView) //내부로직
            routeManager.zoomToRegion(containing: [place.coordinate])
        }
    }
    
    // MARK: - 내부 로직2: 선택된 Plan 내에서 장소 선택할때
    /// Plan 버튼이 활성화된 상태에서 섹션 내 장소를 선택할 때 호출되는 함수입니다.
    /// 최대 2개의 장소까지 선택 가능하며, 선택된 장소 수에 따라 지도에 마커 또는 경로를 표시합니다.
    
    private func selectPlaceInPlan(_ placeID: String, in details: [MapDetail]) {
        guard let routeManager = routeManager else { return }
        let mapView = routeManager.mapView
        
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
        let selectedDetails = details.filter { selectedPlaceIDs.contains($0.id ?? "") }
        
        if selectedDetails.count == 1 {
            addAnnotation(for: selectedDetails[0], to: mapView)
            routeManager.zoomToRegion(containing: [selectedDetails[0].coordinate])
        } else if selectedDetails.count == 2 {
            let start = selectedDetails[0].coordinate
            let end = selectedDetails[1].coordinate
            routeManager.showRoute(from: start, to: end, on: mapView) { _ in }
            addAnnotation(for: selectedDetails[0], to: mapView)
            addAnnotation(for: selectedDetails[1], to: mapView)
            routeManager.zoomToRegion(containing: [start, end])
        }
    }
    
    
    // MARK: - 내부 로직3: [Plan 비활성 상태] 장소 단독 선택 처리
    private func selectPlaceSolo(_ placeID: String) {
        guard let routeManager = routeManager else { return }
        let mapView = routeManager.mapView
        
        if soloSelectedPlaceID == placeID {
            resetSelections()
        } else {
            resetSelections()
            soloSelectedPlaceID = placeID
            
            clearMapView()
            
            if let place = mapDetails.first(where: { $0.id == placeID }) {
                addAnnotation(for: place, to: mapView)
                routeManager.zoomToRegion(containing: [place.coordinate])
            }
        }
    }
}
