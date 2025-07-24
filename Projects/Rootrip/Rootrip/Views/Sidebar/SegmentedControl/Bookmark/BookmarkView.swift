//
//  BookmarkView.swift
//  Rootrip
//
//  Created by MINJEONG on 7/24/25.
//

import SwiftUI
import MapKit

struct BookmarkView: View {
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @EnvironmentObject var mapState: RouteManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(bookmarkManager.bookmarks.filter { $0.id != nil }, id: \.id!) { bookmark in
                    VStack(alignment: .leading) {
                        // MARK: - 섹션별 Bookmark 버튼
                        BookmarkButton(bookmark: bookmark)
                            .environmentObject(bookmarkManager)
                            .environmentObject(mapState)
                            .padding(.leading, 16)
                            .padding(.vertical, 3)

                        // MARK: - 섹션별 장소 목록
                        BookmarkListView(bookmark: bookmark)
                            .environmentObject(bookmarkManager)
                            .environmentObject(mapState)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
        }
    }
}
    #Preview {
        BookmarkView()
    }
