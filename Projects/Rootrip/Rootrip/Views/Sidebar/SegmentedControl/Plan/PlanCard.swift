
import SwiftUI

struct PlanCard: View {
    let projectID: String
    let planID: String

    @State private var poiDataList: [POIData] = []
    @State private var isLoading = true
    @EnvironmentObject var planManager: PlanManager
    @Binding var isEditing: Bool

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                LoadingView()
            } else {
                PlanListContent(poiDataList: poiDataList, isEditing: isEditing)
                    .environmentObject(planManager)
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
        // planManager.mapDetails 변화 감지
        .onChange(of: planManager.mapDetails) { _, _ in
            Task {
                await loadPOIData()
            }
        }
    }

    @MainActor
    private func loadPOIData() async {
        isLoading = true
        
        let mapDetails = planManager.mapDetails(for: planID)
        
        var loadedPOIDataList: [POIData] = []
        let group = DispatchGroup()

        for detail in mapDetails {
            group.enter()
            planManager.convertMapDetailToPOIAnnotation(detail) { annotation in
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

// MARK: - 로딩 뷰
struct LoadingView: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView("장소 불러오는 중...")
                .padding(.vertical, 20)
            Spacer()
        }
    }
}

// MARK: - 리스트 콘텐츠
struct PlanListContent: View {
    let poiDataList: [POIData]
    let isEditing: Bool
    @EnvironmentObject var planManager: PlanManager

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(poiDataList) { poi in
                PlanListRow(poi: poi, isEditing: isEditing)
                    .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - PlanListRow
struct PlanListRow: View {
    let poi: POIData
    let isEditing: Bool
    @EnvironmentObject var planManager: PlanManager

    var body: some View {
        let isSelected = planManager.soloSelectedPlaceID == poi.mapDetailID ||
                         planManager.selectedPlaceIDs.contains(poi.mapDetailID)
        
        let isDeleteSelected = planManager.selectedForDeletionPlaceIDs.contains(poi.mapDetailID)

        HStack(spacing: 8) {
            // 앞쪽 원 아이콘
            if isEditing {
                Image(isDeleteSelected ? "purplemini" : "graymini")
                    .onTapGesture {
                        planManager.togglePlaceForDeletion(poi.mapDetailID)
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

            // 오른쪽 햄버거 아이콘 (이미지만 구현함)
            if isEditing {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.secondary2)
                    .font(.prereg16)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                planManager.toggleSelectedPlace(poi.mapDetailID)
            }
        }
    }
}
