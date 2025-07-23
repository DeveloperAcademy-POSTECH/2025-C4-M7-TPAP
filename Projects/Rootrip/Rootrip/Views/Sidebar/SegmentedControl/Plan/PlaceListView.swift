//
//  PlaceListView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/18/25.
//

import SwiftUI
import MapKit

struct PlaceListView: View {
    let mapDetails: [MapDetail]
    @Binding var selectedPlanID: String?
    @EnvironmentObject var mapState: RouteManager
    @EnvironmentObject var planManager: PlanManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(mapDetails, id: \.id) { detail in
                //MARK: - 장소리스트 버튼 동작
                Button(action: {
                    if let id = detail.id {
                        planManager.toggleSelectedPlace(id)
                    }
                }) {
                    HStack {
                        //TODO: -장소 앞에 들어가는 이미지?로 대체필요
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 48, height: 48)
                        
                        Text(detail.name)
                            .font(.prereg16)
                            .foregroundColor(
                                (planManager.soloSelectedPlaceID == detail.id || planManager.selectedPlaceIDs.contains(detail.id ?? "")) ? Color.accent1 : Color.maintext
                            )
                            .padding(.vertical, 4)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 8)
    }
}
