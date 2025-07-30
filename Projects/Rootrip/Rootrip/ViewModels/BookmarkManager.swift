//
//  BookmarkManager.swift
//  Rootrip
//
//  Created by MINJEONG on 7/24/25.
//

import FirebaseFirestore
import Foundation
import MapKit

/// 사용자가 선택한 북마크를 관리하고, 지도에 해당 위치를 표시하는 매니저 클래스
class BookmarkManager: ObservableObject {
    @Published var bookmarks: [Bookmark] = []
    @Published var mapDetails: [MapDetail] = []
    @Published var annotations: [POIAnnotation] = [] // 장소 이름, 카테고리, 지도 검색 결과 기반
    @Published var selectedForDeletionPlaceIDs: [String] = []
    @Published var selectedBookmarkIDsForEdit: [String] = []
    
    @Published var selectedBookmarkID: String? = nil
    
    private var locationManager: LocationManager?
    private let repository = BookmarkRepository()
    private let mapDetailRepository: MapDetailRepositoryProtocol = MapDetailRepository()
    
    func configure(with locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    @MainActor
    func loadBookmarks(for projectID: String) async {
        do {
            let bookmarkCollectionRef = Firestore.firestore()
                .collection("Rootrip")
                .document(projectID)
                .collection("bookmarks")
            
            let snapshot = try await bookmarkCollectionRef.getDocuments()
            let bookmarks: [Bookmark] = try snapshot.documents.map { doc in
                var b = try doc.data(as: Bookmark.self)
                b.id = doc.documentID
                return b
            }
            
            self.bookmarks = bookmarks
            self.mapDetails = []
            self.annotations = []
            
            // 각 북마크의 mapDetails도 로딩
            for bookmark in bookmarks {
                guard let id = bookmark.id else { continue }
                let details = try await repository.loadBookmark(
                    projectID: projectID,
                    bookmarkID: id
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
            print("BookmarkManager Error - can't read Bookmarks from firestore: \(error.localizedDescription)")
        }
    }
    
    func mapDetails(for bookmarkID: String?) -> [MapDetail] {
        guard let id = bookmarkID else { return [] }
        return mapDetails.filter { $0.containerID == id }
    }
    
    // 단일 선택
    func toggleBookmark(_ detail: MapDetail) {
        guard let locationManager = locationManager else {
            print("❌ BookmarkManager: LocationManager is nil")
            return
        }
        guard let mapView = locationManager.mapView else {
            print("❌ BookmarkManager: mapView not set in LocationManager")
            return
        }
        
        if selectedBookmarkID == detail.id {
            resetSelection()
        } else {
            selectedBookmarkID = detail.id
            addAnnotations(for: [detail])
        }
    }
    
    // 전체 섹션 선택
    func toggleSelectedBookmarkSection(_ bookmarkID: String?) {
        guard let id = bookmarkID else { return }
        guard let locationManager = locationManager else {
            print("❌ BookmarkManager: LocationManager is nil")
            return
        }
        guard let mapView = locationManager.mapView else {
            print("❌ BookmarkManager: mapView not set in LocationManager")
            return
        }
        
        let details = mapDetails.filter { $0.containerID == id }
        
        if selectedBookmarkID == id {
            resetSelection()
        } else {
            selectedBookmarkID = id
            addAnnotations(for: details)
        }
    }
    
    // annotation 표시
    private func addAnnotations(for details: [MapDetail]) {
        guard let locationManager = locationManager else {
            print("❌ BookmarkManager: LocationManager is nil for addAnnotations")
            return
        }
        guard let mapView = locationManager.mapView else {
            print("❌ BookmarkManager: mapView not set for addAnnotations")
            return
        }
        
        DispatchQueue.main.async {
            mapView.removeAnnotations(mapView.annotations)
            
            let annotations = details.map { detail in
                let annotation = MKPointAnnotation()
                annotation.coordinate = detail.coordinate
                return annotation
            }
            
            mapView.addAnnotations(annotations)
            locationManager.zoomToRegion(containing: details.map { $0.coordinate })
            
            print("📍 BookmarkManager: Added \(annotations.count) annotations")
        }
    }
    
    func resetSelection() {
        selectedBookmarkID = nil
        
        guard let locationManager = locationManager else {
            print("❌ BookmarkManager: LocationManager is nil for resetSelection")
            return
        }
        guard let mapView = locationManager.mapView else {
            print("❌ BookmarkManager: mapView not set for resetSelection")
            return
        }
        
        DispatchQueue.main.async {
            mapView.removeAnnotations(mapView.annotations)
            print("📍 BookmarkManager: Reset selection and removed annotations")
        }
    }
    
    func convertMapDetailToPOIAnnotation(_ mapDetail: MapDetail, completion: @escaping (POIAnnotation?) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = mapDetail.name
        request.region = MKCoordinateRegion(center: mapDetail.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let item = response?.mapItems.first else {
                print("❌ 장소 검색 실패: \(error?.localizedDescription ?? "알 수 없음")")
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
    
    // MARK: - 편집 모드 토글 함수들
    func togglePlaceForDeletion(_ placeID: String) {
        if selectedForDeletionPlaceIDs.contains(placeID) {
            selectedForDeletionPlaceIDs.removeAll { $0 == placeID }
        } else {
            selectedForDeletionPlaceIDs.append(placeID)
        }
    }
    
    func toggleEditSelection(for bookmarkID: String) {
        if selectedBookmarkIDsForEdit.contains(bookmarkID) {
            selectedBookmarkIDsForEdit.removeAll { $0 == bookmarkID }
        } else {
            selectedBookmarkIDsForEdit.append(bookmarkID)
        }
    }
    
    // MARK: - 삭제 관련 함수들
    @MainActor
    func deleteBookmarkSection(projectID: String, bookmarkID: String) async {
        do {
            try await repository.deleteBookmark(projectID: projectID, bookmarkID: bookmarkID)
            
            self.bookmarks.removeAll { $0.id == bookmarkID }
            self.mapDetails.removeAll { $0.containerID == bookmarkID }
            
        } catch {
            print("Bookmark 섹션 삭제 실패: \(error)")
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
    
    // MARK: - 생성 함수
    @MainActor
    func createNewBookmark(projectID: String) async {
        do {
            // 기존 북마크 개수로 제목 생성
            let count = bookmarks.count
            let newTitle = "내 보관함 \(count + 1)"
            
            try await repository.createBookmark(
                projectID: projectID,
                title: newTitle,
                isDefault: false
            )
            
            // 새로 생성된 북마크 목록 다시 로드
            await loadBookmarks(for: projectID)
            
        } catch {
            print("Bookmark 생성 실패: \(error)")
        }
    }
    
    // MARK: - 선택 상태 관리
    /// 선택 상태 초기화 + 마커/경로 제거
    func resetSelections() {
        selectedForDeletionPlaceIDs = []
        selectedBookmarkIDsForEdit = []
        resetSelection() // 기존 함수 호출
    }
}
