//
//  SectionButton.swift
//  Sidebar
//
//  Created by MINJEONG on 7/17/25.
//

import SwiftUI
import MapKit

/// 플랜(섹션) 하나를 표시하는 버튼 뷰입니다.
/// 버튼을 누르면 해당 섹션의 장소들을 지도에 표시하고, 경로를 보여줍니다.
struct PlanButton: View {
    /// 지도 관련 기능을 제공하는 객체입니다.
    @EnvironmentObject var routeManager: RouteManager
    @EnvironmentObject var planManager: PlanManager
    var plan: Plan
    
    /// 버튼 클릭 시 섹션이 선택되면 지도에 해당 섹션의 장소를 핀으로 표시하고 경로를 보여줍니다.
    /// 이미 선택된 섹션을 다시 누르면 선택을 해제하고 지도에서 관련 요소를 제거합니다.
    var body: some View {
        Button(action: {
            if planManager.selectedPlanID == plan.id {
                planManager.selectPlan(nil)
            } else {
                planManager.selectPlan(plan.id)
            }
        }) {
            Text(plan.title)
                .sectionButtonLable(isSelected: planManager.selectedPlanID == plan.id)
                    }
        .onAppear {
            planManager.configure(with: routeManager)
        }
    }
}
