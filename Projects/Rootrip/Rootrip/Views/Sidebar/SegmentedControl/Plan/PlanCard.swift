//
//  PlaceListForPlanView.swift
//  Rootrip
//
//  Created by MINJEONG on 7/24/25.
//

import SwiftUI

struct PlanCard: View {
    let mapDetails: [MapDetail]                // 보여줄 장소 리스트
    @EnvironmentObject var planManager: PlanManager

    var body: some View {
        VStack(spacing: 20) {
            ForEach(mapDetails, id: \.id) { detail in
                Button(action: {
                    if let id = detail.id {
                        planManager.toggleSelectedPlace(id)
                    }
                }) {
                    MapDetailitem(
                        detail: detail,
                        isSelected: planManager.soloSelectedPlaceID == detail.id || planManager.selectedPlaceIDs.contains(detail.id ?? "")
                    )
                }
            }
        }
        .padding(.all, 16)
        .frame(width: 216)
        .background(.secondary4)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
