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

    @State private var poiDataList: [POIData] = []
    @State private var isLoading = true
    @EnvironmentObject var planManager: PlanManager

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("장소 불러오는 중...")
            } else {
                ForEach(poiDataList) { poi in
                    poiCard(for: poi)
                }
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
    }

    @ViewBuilder
    private func poiCard(for poi: POIData) -> some View {
        Button(action: {
            planManager.toggleSelectedPlace(poi.mapDetailID) // 🔥 변경된 부분
        }) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: poi.imageName)
                    .resizable()
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(poi.name)
                        .font(.prereg16)


                    if planManager.soloSelectedPlaceID == poi.mapDetailID || planManager.selectedPlaceIDs.contains(poi.mapDetailID) {
                        Text("선택됨")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
        }
    }

    @MainActor
    private func loadPOIData() async {
        do {
            let repository = MapDetailRepository()
            let mapDetails = try await repository.loadMapDetailsFromPlan(projectID: projectID, containerID: planID)
            print("✅ 불러온 MapDetail 개수: \(mapDetails.count)")
            for detail in mapDetails {
                print("📍 detail.coordinate = \(detail.latitude), \(detail.longitude)")
            }

            var loadedPOIDataList: [POIData] = []
            let group = DispatchGroup()

            for detail in mapDetails {
                group.enter()
                planManager.convertMapDetailToPOIAnnotation(detail) { annotation in
                    if let annotation = annotation {
                        print("📌 keyword = \(annotation.keyword)")
                        
                        let data = POIData(
                            mapDetailID: detail.id ?? "",
                            name: detail.name, // 🔥 mapDetail의 name 사용
                            keyword: annotation.keyword // 🔥 카테고리는 추정값 사용
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

        } catch {
            print("PlanCard Error - mapDetails 로딩 실패: \(error.localizedDescription)")
        }
    }
}
