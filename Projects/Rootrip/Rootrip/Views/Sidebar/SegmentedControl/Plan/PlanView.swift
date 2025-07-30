//
//  ScheduleView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/17/25.
//

import CoreLocation
import MapKit
import SwiftUI

struct PlanView: View {
    @EnvironmentObject var planManager: PlanManager
    @EnvironmentObject var mapState: LocationManager
    @Binding var isEditing: Bool
    
    let projectID: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                ForEach(planManager.plans, id: \.id) { plan in
                    VStack(alignment: .leading) {
                        // MARK: - 섹션별 Plan 버튼
                        PlanButton(plan: plan, isEditing: $isEditing)
                            .environmentObject(planManager)
                            .environmentObject(mapState)
                            .padding(.leading, 22)
                        
                        // MARK: - 장소 목록
                        PlanCard(
                            projectID: projectID,
                            planID: plan.id ?? "",
                            isEditing: $isEditing
                        )
                        .padding(.horizontal, 22)
                        .padding(.vertical, 15)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
        }
        .onChange(of: isEditing) { _, newValue in
            if newValue {
                planManager.resetSelections()
            }
        }
    }
}



//#Preview(traits: .landscapeLeft) {
//    PlanView()
//        .environmentObject(PlanManager())
//        .environmentObject(LocationManager())
//}
