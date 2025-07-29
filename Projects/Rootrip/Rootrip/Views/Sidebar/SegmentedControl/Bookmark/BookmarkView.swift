//
//  BookmarkView.swift
//  Rootrip
//
//  Created by MINJEONG on 7/24/25.
//

import MapKit
import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @EnvironmentObject var mapState: LocationManager
    
    let projectID: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(
                    bookmarkManager.bookmarks.filter { $0.id != nil },
                    id: \.id!
                ) { bookmark in
                    VStack(alignment: .leading) {
                        // MARK: - 섹션별 Bookmark 버튼
                        BookmarkButton(bookmark: bookmark)
                            .environmentObject(bookmarkManager)
                            .environmentObject(mapState)
                            .padding(.leading, 22)

                        // MARK: - 섹션별 장소 목록
                        BookmarkCard(
                            projectID: projectID,
                            bookmarkID: bookmark.id!
                        )
                        .padding(.horizontal, 22)
                        .padding(.vertical, 15)
                    }
                }
                Spacer()
            }
            .onAppear {
                Task {
                    await bookmarkManager.loadBookmarks(for: projectID)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
        }
    }
}
