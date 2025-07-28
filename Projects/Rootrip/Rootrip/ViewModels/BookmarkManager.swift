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
    @Published var selectedBookmarkID: String? = nil

    private var routeManager: RouteManager?
    private let repository = BookmarkRepository()

    func configure(with routeManager: RouteManager) {
        self.routeManager = routeManager
    }

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

            await MainActor.run {
                self.bookmarks = bookmarks
            }

            // 각 북마크의 mapDetails도 로딩
            var allDetails: [MapDetail] = []
            for bookmark in bookmarks {
                guard let id = bookmark.id else { continue }
                let details = try await repository.loadBookmark(
                    projectID: projectID,
                    bookmarkID: id
                )
                allDetails.append(contentsOf: details)
            }

            await MainActor.run {
                self.mapDetails = allDetails
            }
        } catch {
            print(
                "BookmarkManager Error - can't read Bookmarks from firestore: \(error.localizedDescription)"
            )
        }
    }

    func mapDetails(for bookmarkID: String?) -> [MapDetail] {
        guard let id = bookmarkID else { return [] }
        return mapDetails.filter { $0.containerID == id }
    }

    // 단일 선택
    func toggleBookmark(_ detail: MapDetail) {
        guard let routeManager = routeManager else { return }

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
        guard let routeManager = routeManager else { return }

        let mapView = routeManager.mapView
        mapView.removeAnnotations(mapView.annotations)

        let annotations = details.map {
            let annotation = MKPointAnnotation()
            annotation.coordinate = $0.coordinate
            return annotation
        }

        mapView.addAnnotations(annotations)
        routeManager.zoomToRegion(containing: details.map { $0.coordinate })
    }

    func resetSelection() {
        selectedBookmarkID = nil
        routeManager?.mapView.removeAnnotations(
            routeManager?.mapView.annotations ?? []
        )
    }
}
