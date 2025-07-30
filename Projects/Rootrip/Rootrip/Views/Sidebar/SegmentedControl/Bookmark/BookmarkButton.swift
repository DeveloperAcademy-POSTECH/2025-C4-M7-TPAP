//
//  BookmarkButton.swift
//  Rootrip
//
//  Created by MINJEONG on 7/24/25.
//

import SwiftUI
import MapKit

/// 북마크 버튼
struct BookmarkButton: View {
    
    @EnvironmentObject var locationManager: LocationManager // 현재 지도 상태를 관리하는 객체
    @EnvironmentObject var bookmarkManager: BookmarkManager // 북마크 상태를 관리하는 객체
    let bookmark: Bookmark // 개별 북마크 데이터
    @Binding var isEditing: Bool

    var body: some View {
        // MARK: - 북마크 버튼을 눌렀을 때의 동작
        Button(action: {
            guard let bookmarkID = bookmark.id else { return }
            
            if isEditing {
                bookmarkManager.toggleEditSelection(for: bookmarkID)
            } else {
                if bookmarkManager.selectedBookmarkID == bookmarkID {
                    bookmarkManager.resetSelection()
                } else {
                    bookmarkManager.toggleSelectedBookmarkSection(bookmark.id)
                }
            }
        }) {
            HStack(spacing: 8) {
                if isEditing {
                    Image(bookmarkManager.selectedBookmarkIDsForEdit.contains(bookmark.id ?? "")
                          ? "purplebig"
                          : "graybig")
                    .foregroundColor(.accentColor)
                }
                
                // MARK: - 버튼 레이블 구성
                Text(bookmark.title)
                    .sectionButtonLable(
                        isSelected: !isEditing && bookmarkManager.selectedBookmarkID == bookmark.id
                    )
            }
        }
        .onChange(of: isEditing) { _, newValue in
            if newValue {
                bookmarkManager.resetSelections()
            }
        }
    }
}
