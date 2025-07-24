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
    @Published var bookmarks: [Bookmark] = sampleBookMarks
    @Published var mapDetails: [MapDetail] = sampleMapDetails

    private var routeManager: RouteManager?

    /// 외부에서 RouteManager를 설정하는 초기 구성 메서드
    /// - Parameter routeManager: 외부에서 주입되는 지도 상태 관리자
    func configure(with routeManager: RouteManager) {
        self.routeManager = routeManager
    }

    /// 주어진 장소(MapDetail)를 북마크로 토글(선택/해제)하며, 지도에 어노테이션 추가 또는 제거
    /// - Parameter detail: 북마크 처리할 장소 정보
    func toggleBookmark(_ detail: MapDetail) {
        guard let routeManager = routeManager else { return }
        let mapView = routeManager.mapView

        if selectedBookmarkID == detail.id {
            // 같은 북마크 누르면 제거
            selectedBookmarkID = nil
            mapView.removeAnnotations(mapView.annotations)
        } else {
            // 새로운 북마크 선택
            selectedBookmarkID = detail.id

            mapView.removeAnnotations(mapView.annotations)

            let annotation = MKPointAnnotation()
            annotation.coordinate = detail.coordinate
            annotation.title = detail.name
            mapView.addAnnotation(annotation)
            routeManager.zoomToRegion(containing: [detail.coordinate])
        }
    }
}
