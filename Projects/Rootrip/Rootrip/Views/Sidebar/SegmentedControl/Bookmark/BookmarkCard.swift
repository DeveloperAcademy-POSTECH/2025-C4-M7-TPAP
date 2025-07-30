
import SwiftUI

struct BookmarkCard: View {
    let projectID: String
    let bookmarkID: String
    
    @State private var poiDataList: [POIData] = []
    @State private var isLoading = true
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                LoadingView()
            } else {
                BookmarkListContent(poiDataList: poiDataList, isEditing: isEditing)
                    .environmentObject(bookmarkManager)
            }
        }
        .padding(.all, 16)
        .frame(width: 216)
        .background(.secondary4)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            Task {
                await loadPOIData()
            }
        }
        .onChange(of: bookmarkManager.mapDetails) { _, _ in
            Task {
                await loadPOIData()
            }
        }
    }
    
    @MainActor
    private func loadPOIData() async {
        isLoading = true
        
        let mapDetails = bookmarkManager.mapDetails(for: bookmarkID)
        
        var loadedPOIDataList: [POIData] = []
        let group = DispatchGroup()

        for detail in mapDetails {
            group.enter()
            bookmarkManager.convertMapDetailToPOIAnnotation(detail) { annotation in
                if let annotation = annotation {
                    let data = POIData(
                        mapDetailID: detail.id ?? "",
                        name: detail.name,
                        keyword: annotation.keyword
                    )
                    loadedPOIDataList.append(data)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.poiDataList = loadedPOIDataList
            self.isLoading = false
        }
    }
}

// MARK: - 북마크 리스트 컨텐츠
struct BookmarkListContent: View {
    let poiDataList: [POIData]
    let isEditing: Bool
    @EnvironmentObject var bookmarkManager: BookmarkManager
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(poiDataList) { poi in
                BookmarkListRow(poi: poi, isEditing: isEditing)
                    .padding(.vertical, 8)
                    .environmentObject(bookmarkManager)
            }
        }
    }
}

// MARK: - BookmarkListRow
struct BookmarkListRow: View {
    let poi: POIData
    let isEditing: Bool
    @EnvironmentObject var bookmarkManager: BookmarkManager
    
    var body: some View {
        let isSelected = bookmarkManager.selectedBookmarkID == poi.mapDetailID ||
        bookmarkManager.selectedBookmarkID?.contains(poi.mapDetailID) == true
        
        let isDeleteSelected = bookmarkManager.selectedForDeletionPlaceIDs.contains(poi.mapDetailID)
        
        HStack(spacing: 8) {
            // 앞쪽 원 아이콘
            if isEditing {
                Image(isDeleteSelected ? "purplemini" : "graymini")
                    .onTapGesture {
                        bookmarkManager.togglePlaceForDeletion(poi.mapDetailID)
                    }
            }
            
            // 아이콘
            Image(isSelected ? poi.selectedImageName : poi.imageName)
            
            // 텍스트
            Text(poi.name)
                .font(.prereg16)
                .foregroundColor(isSelected ? .accent1 : .maintext)
                .lineLimit(1)
            
            Spacer()
            
            // 오른쪽 햄버거 아이콘
            if isEditing {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.secondary2)
                    .font(.prereg16)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                if let detail = bookmarkManager.mapDetails.first(where: { $0.id == poi.mapDetailID }) {
                    bookmarkManager.toggleBookmark(detail)
                }
            }
        }
    }
}
