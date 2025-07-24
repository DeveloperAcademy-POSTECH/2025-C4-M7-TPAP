//
//  BookmarkListView.swift
//  Rootrip
//
//  Created by MINJEONG on 7/24/25.
//
//
//import SwiftUI
//import MapKit
//
//struct BookmarkListView: View {
//    @EnvironmentObject var bookmarkManager: BookmarkManager
//    @EnvironmentObject var routeManager: RouteManager
//    var bookmark: Bookmark
//
//    var body: some View {
//        
//        let filteredDetails = bookmarkManager.mapDetails(for: bookmark.id)
//
//        VStack(alignment: .leading, spacing: 8) {
//            // 필터링된 장소 목록을 순회하며 버튼으로 표시
//            ForEach(filteredDetails, id: \.id) { detail in
//                Button(action: {
//                    bookmarkManager.toggleBookmark(detail)
//                }) {
//                    HStack {
//                        // 장소 앞에 표시될 회색 사각형 아이콘
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.gray.opacity(0.3))
//                            .frame(width: 48, height: 48)
//                        // 장소 이름 텍스트 (선택 여부에 따라 색상 변경)
//                        Text(detail.name)
//                            .font(.prereg16)
//                            .foregroundColor(
//                                bookmarkManager.selectedBookmarkID == detail.id ? Color.accent1 : Color.maintext
//                            )
//                            .padding(.vertical, 4)
//
//                        Spacer()
//                    }
//                }
//                .padding(.horizontal)
//            }
//        }
//        .padding(.top, 8)
//        .onAppear {
//            bookmarkManager.configure(with: routeManager)
//        }
//    }
//}
