//
//  ScheduleView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/17/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct PlanView: View {
    @EnvironmentObject var planManager: PlanManager
    @EnvironmentObject var mapState: RouteManager
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(planManager.plans, id: \.id) { plan in
                    VStack(alignment: .leading) {
                        // MARK: - 섹션별 Plan 버튼
                        PlanButton(plan: plan)
                            .environmentObject(planManager)
                            .environmentObject(mapState)
                            .padding(.leading, 16)
                            .padding(.vertical, 3)
                        
                        // MARK: - 장소 목록
                        PlaceListView(
                            mapDetails: planManager.mapDetails(for: plan.id ?? ""),
                            selectedPlanID: $planManager.selectedPlanID
                        )
                    }
                }
//                // MARK: - 섹션추가버튼
//                //-TODO: 편집 버튼 누르면 뜨도록 변경필요
//                //현재는 그냥 UI확인상 추가해둠
//                Button(action: {
//                    planManager.addSection()
//                }) {
//                    HStack {
//                        Image(systemName: "plus.circle.fill")
//                        Text("섹션 추가")
//                    }
//                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    PlanView()
        .environmentObject(PlanManager())
        .environmentObject(RouteManager())
}
