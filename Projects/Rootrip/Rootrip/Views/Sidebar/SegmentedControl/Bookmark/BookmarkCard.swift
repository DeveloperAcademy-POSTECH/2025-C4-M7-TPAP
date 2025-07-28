////
////  BookmarkSectionView.swift
////  Rootrip
////
////  Created by MINJEONG on 7/24/25.
////
//
//import SwiftUI
//
//struct BookmarkCard: View {
//    let details: [MapDetail]  // 해당 bookmark에 속하는 장소 목록
//    @EnvironmentObject var bookmarkManager: BookmarkManager
//    
//    var body: some View {
//        // 북마크 리스트 카드 스타일
//        VStack(spacing: 20){
//            ForEach(details, id: \.id) { detail in
//                Button(action: {
//                    bookmarkManager.toggleBookmark(detail)
//                }) {
////                    MapDetailitem(
////                        detail: detail,
////                        isSelected: bookmarkManager.selectedBookmarkID == detail.id
////                    )
//                    Text("")
//                }
//            }
//        }
//        .padding(.all, 16)
//        .frame(width: 216)
//        .background(.secondary4)
//        .clipShape(RoundedRectangle(cornerRadius: 20))
//    }
//}
import SwiftUI

struct BookmarkCard: View {
    let projectID: String
    let bookmarkID: String

    @State private var details: [MapDetail] = []
    @State private var isLoading = true
    @EnvironmentObject var bookmarkManager: BookmarkManager

    var body: some View {
        VStack(spacing: 20){
            if isLoading {
                ProgressView("북마크 불러오는 중...")
            } else {
                ForEach(details, id: \.id) { detail in
                    Button(action: {
                        bookmarkManager.toggleBookmark(detail)
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("위도: \(detail.latitude), 경도: \(detail.longitude)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            if bookmarkManager.selectedBookmarkID == detail.id {
                                Text("선택됨")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(.all, 16)
        .frame(width: 216)
        .background(.secondary4)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            Task {
                await loadBookmarkDetails()
            }
        }
    }

    @MainActor
    private func loadBookmarkDetails() async {
        do {
            let repository = BookmarkRepository()
            self.details = try await repository.loadBookmark(projectID: projectID, bookmarkID: bookmarkID)
            self.isLoading = false
        } catch {
            print("❌ BookmarkCard - details 로딩 실패: \(error.localizedDescription)")
        }
    }
}
