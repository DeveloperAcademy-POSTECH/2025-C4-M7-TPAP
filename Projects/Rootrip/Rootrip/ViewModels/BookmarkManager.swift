//
//  BookmarkManager.swift
//  Rootrip
//
//  Created by MINJEONG on 7/24/25.
//

import Foundation
import MapKit

/// 사용자가 선택한 북마크를 관리하고, 지도에 해당 위치를 표시하는 매니저 클래스
class BookmarkManager: ObservableObject {
    @Published var selectedBookmarkID: String? = nil
    //TODO: -샘플 훗날제고
    @Published var bookmarks: [Bookmark] = sampleBookMarks
    @Published var mapDetails: [MapDetail] = sampleMapDetails

    private var routeManager: RouteManager?
    
    // MARK: - 북마크 ID → planID 매핑
    private let planIDMapping: [String: String] = [
        "bookmarkA": "planA",
        "bookmarkB": "planB"
    ]

    // MARK: - 북마크에 해당하는 장소 리스트 반환
    func mapDetails(for bookmarkID: String?) -> [MapDetail] {
        guard let id = bookmarkID,
              let planID = planIDMapping[id] else { return [] }
        return mapDetails.filter { $0.planID == planID }
    }

    // MARK: - 외부에서 지도 상태연결
    /// 외부에서 RouteManager를 설정하는 초기 구성 메서드
    /// - Parameter routeManager: 외부에서 주입되는 지도 상태 관리자
    func configure(with routeManager: RouteManager) {
        self.routeManager = routeManager
    }
    
    // MARK: - 주어진 장소 리스트를 지도에 어노테이션으로 표시
    private func addAnnotations(for details: [MapDetail]) {
        guard let routeManager = routeManager else { return }
        let mapView = routeManager.mapView

        mapView.removeAnnotations(mapView.annotations)

        let annotations = details.map {
            let a = MKPointAnnotation()
            a.coordinate = $0.coordinate
            a.title = $0.name
            return a
        }

        mapView.addAnnotations(annotations)
        routeManager.zoomToRegion(containing: details.map { $0.coordinate })
    }
    
    // MARK: - 선택 상태 초기화
    func resetSelection() {
        selectedBookmarkID = nil
        routeManager?.mapView.removeAnnotations(routeManager?.mapView.annotations ?? [])
    }
    
    // MARK: - 단일 장소 토글
    func toggleBookmark(_ detail: MapDetail) {
        guard let routeManager = routeManager else { return }

        if selectedBookmarkID == detail.id {
            resetSelection()
        } else {
            selectedBookmarkID = detail.id
            addAnnotations(for: [detail])
        }
    }

    // MARK: - 북마크 섹션 토글 (섹션의 모든 장소 표시)
    func toggleSelectedBookmarkSection(_ sectionID: String?) {
        guard let sectionID else { return }
        guard let planID = planIDMapping[sectionID] else { return }

        let details = mapDetails.filter { $0.planID == planID }

        if selectedBookmarkID == sectionID {
            resetSelection()
        } else {
            selectedBookmarkID = sectionID
            addAnnotations(for: details)
        }
    }
}
