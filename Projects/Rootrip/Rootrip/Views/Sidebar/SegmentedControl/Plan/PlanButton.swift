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
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var planManager: PlanManager
    var plan: Plan
    @Binding var isEditing: Bool
    
    
    /// 버튼 클릭 시 섹션이 선택되면 지도에 해당 섹션의 장소를 핀으로 표시하고 경로를 보여줍니다.
    /// 이미 선택된 섹션을 다시 누르면 선택을 해제하고 지도에서 관련 요소를 제거합니다.
    var body: some View {
        Button(action: {
            guard let planID = plan.id else { return }
            
            if isEditing {
                planManager.toggleEditSelection(for: planID)
            } else {
                if planManager.selectedPlanID == planID {
                    planManager.selectPlan(nil)
                } else {
                    planManager.selectPlan(planID)
                }
            }
        }) {
            HStack(spacing: 8) {
                if isEditing {
                    Image(planManager.selectedPlanIDsForEdit.contains(plan.id ?? "")
                          ? "purplebig"
                          : "graybig")
                    .foregroundColor(.accentColor)
                }
                
                Text(plan.title)
                    .sectionButtonLable(
                        isSelected: !isEditing && planManager.selectedPlanID == plan.id
                    )
            }
        }
        .onChange(of: isEditing) { _, newValue in
            if newValue {
                planManager.resetSelections()
            }
        }
    }
}
