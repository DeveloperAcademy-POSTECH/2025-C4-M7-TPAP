//
//  PlaceListForPlanView.swift
//  Rootrip
//
//  Created by MINJEONG on 7/24/25.
//

//import SwiftUI
//
//struct PlanCard: View {
//    let mapDetails: [MapDetail]                // 보여줄 장소 리스트
//    @EnvironmentObject var planManager: PlanManager
//
//    var body: some View {
//        VStack(spacing: 20) {
//            ForEach(mapDetails, id: \.id) { detail in
//                Button(action: {
//                    if let id = detail.id {
//                        planManager.toggleSelectedPlace(id)
//                    }
//                }) {
//                    MapDetailitem(
//                        detail: detail,
//                        isSelected: planManager.soloSelectedPlaceID == detail.id || planManager.selectedPlaceIDs.contains(detail.id ?? "")
//                    )
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

struct PlanCard: View {
    let projectID: String
    let planID: String

    @State private var mapDetails: [MapDetail] = []
    @State private var isLoading = true
    @EnvironmentObject var planManager: PlanManager

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("장소 불러오는 중...")
            } else {
                ForEach(mapDetails, id: \.id) { detail in
                    Button(action: {
                        if let id = detail.id {
                            planManager.toggleSelectedPlace(id)
                        }
                    }) {
                        // TODO: 선택됨에 따른 액션 추가해야함(아이콘 및 색상표시. 뭐 기타등등 planManager의 기능들)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("위도: \(detail.latitude), 경도: \(detail.longitude)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            if planManager.soloSelectedPlaceID == detail.id || planManager.selectedPlaceIDs.contains(detail.id ?? "") {
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
                await loadMapDetails()
            }
        }
    }

    @MainActor
    private func loadMapDetails() async {
        do {
            let repository = MapDetailRepository()
            self.mapDetails = try await repository.loadMapDetails(projectID: projectID, planID: planID)
            self.isLoading = false
        } catch {
            print("❌ PlanCard - mapDetails 로딩 실패: \(error.localizedDescription)")
        }
    }
}
