//
//  SidebarView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/17/25.
//

import SwiftUI

struct SidebarView: View {
    @State private var selectedIndex = 0
    @EnvironmentObject var planManager: PlanManager
    @EnvironmentObject var bookmarkManager: BookmarkManager
    var body: some View {
        VStack{
            HStack{
                Spacer()
                //-TODO: 편집 버튼으로 바꿔야함(섹션추가,삭제,순서변경 기능)
                //UI확인상 넣어둠
                Text("편집")
                    .foregroundColor(.purple)
                    .font(.system(size: 16))
            }
            .padding(.top, 64)
            .padding(.trailing, 16)
            
        //-MARK: SegmentedContolView의 선택된 탭 인덱스 변경될 때
        ///탭 인덱스 변경시 어노테이션 및 경로 초기화
            SegmentedContolView(selectedIndex: $selectedIndex)
                .onChange(of: selectedIndex) { _, newValue in
                    if newValue == 0 {
                        bookmarkManager.resetSelection()
                    } else if newValue == 1 {
                        planManager.resetSelections()
                        planManager.selectedPlanID = nil
                    } else {
                        // 참여자 뷰로 넘어갈 때도 지도 클리어
                        bookmarkManager.resetSelection()
                        planManager.resetSelections()
                        planManager.selectedPlanID = nil
                    }
                }
            Spacer()
        }
        .frame(width: 259)
        .frame(maxHeight: .infinity)
        .background(.mainbackground)
        .transition(.move(edge: .leading))
    }
}

#Preview(traits: .landscapeLeft) {
    SidebarView()
        .environmentObject(PlanManager())
        .environmentObject(RouteManager())
        .environmentObject(BookmarkManager())
}
