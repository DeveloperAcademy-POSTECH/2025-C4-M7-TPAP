//
//  BookmarkListView.swift
//  Rootrip
//
//  Created by MINJEONG on 7/24/25.
//

import SwiftUI
import MapKit

struct BookmarkListView: View {
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @EnvironmentObject var routeManager: RouteManager
    var bookmark: Bookmark

    var body: some View {
        // 북마크 ID(bookmark.id)에 따라 대응되는 장소 planID를 매핑하는 딕셔너리
        let planIDForBookmarkID: [String: String] = [
            "bookmarkA": "planA",
            "bookmarkB": "planB"
        ]
        
        // 해당 북마크에 대응되는 planID를 기준으로 장소들을 필터링
        let filteredDetails = bookmarkManager.mapDetails.filter {
            $0.planID == planIDForBookmarkID[bookmark.id ?? ""]
        }

        VStack(alignment: .leading, spacing: 8) {
            // 필터링된 장소 목록을 순회하며 버튼으로 표시
            ForEach(filteredDetails, id: \.id) { detail in
                Button(action: {
                    bookmarkManager.toggleBookmark(detail)
                }) {
                    HStack {
                        // 장소 앞에 표시될 회색 사각형 아이콘
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 48, height: 48)
                        // 장소 이름 텍스트 (선택 여부에 따라 색상 변경)
                        Text(detail.name)
                            .font(.prereg16)
                            .foregroundColor(
                                bookmarkManager.selectedBookmarkID == detail.id ? Color.accent1 : Color.maintext
                            )
                            .padding(.vertical, 4)

                        Spacer()
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 8)
        .onAppear {
            bookmarkManager.configure(with: routeManager)
        }
    }
}
