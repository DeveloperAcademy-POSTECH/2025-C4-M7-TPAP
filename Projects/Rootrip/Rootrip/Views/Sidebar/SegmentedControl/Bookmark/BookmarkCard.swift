//
//  BookmarkSectionView.swift
//  Rootrip
//
//  Created by MINJEONG on 7/24/25.
//

import SwiftUI

struct BookmarkCard: View {
    let details: [MapDetail]  // 해당 bookmark에 속하는 장소 목록
    @EnvironmentObject var bookmarkManager: BookmarkManager
    
    var body: some View {
        // 북마크 리스트 카드 스타일
        VStack(spacing: 20){
            ForEach(details, id: \.id) { detail in
                Button(action: {
                    bookmarkManager.toggleBookmark(detail)
                }) {
//                    MapDetailitem(
//                        detail: detail,
//                        isSelected: bookmarkManager.selectedBookmarkID == detail.id
//                    )
                    Text("")
                }
            }
        }
        .padding(.all, 16)
        .frame(width: 216)
        .background(.secondary4)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
