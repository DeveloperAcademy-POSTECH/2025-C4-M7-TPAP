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
    
    let projectID: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {

                ForEach(planManager.plans) { plan in
                    VStack(alignment: .leading) {
                        // MARK: - 섹션별 Plan 버튼
                        PlanButton(plan: plan)
                            .environmentObject(planManager)
                            .environmentObject(mapState)
                            .padding(.leading, 22)
                        
                        // MARK: - 장소 목록
                        PlanCard(
                            projectID: projectID,
                            planID: plan.id ?? ""
                        )
                        .padding(.horizontal, 22)
                        .padding(.vertical, 15)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
        }
    }
}

//#Preview(traits: .landscapeLeft) {
//    PlanView()
//        .environmentObject(PlanManager())
//        .environmentObject(LocationManager())
//}
