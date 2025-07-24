//
//  BookmarkButton.swift
//  Rootrip
//
//  Created by MINJEONG on 7/24/25.
//

import SwiftUI
import MapKit

/// 북마크 버튼 컴포넌트
struct BookmarkButton: View {
    @EnvironmentObject var routeManager: RouteManager // 현재 지도 상태를 관리하는 객체
    @EnvironmentObject var bookmarkManager: BookmarkManager // 북마크 상태를 관리하는 객체

    let bookmark: Bookmark // 개별 북마크 데이터

    var body: some View {
        // MARK: - 북마크 버튼을 눌렀을 때의 동작
        Button(action: {
            // 북마크에 해당하는 장소(MapDetail)를 찾아서 toggleBookmark 실행
            if let detail = bookmarkManager.mapDetails.first(where: { $0.id == bookmark.id }) {
                bookmarkManager.toggleBookmark(detail)
            }
        }) {
            // MARK: - 버튼 레이블 구성
            Text(bookmark.title)
                .sectionButtonLable(isSelected: bookmarkManager.selectedBookmarkID == bookmark.id)
        }
        // 뷰가 나타날 때 routeManager 설정
        .onAppear {
            bookmarkManager.configure(with: routeManager)
        }
    }
}
