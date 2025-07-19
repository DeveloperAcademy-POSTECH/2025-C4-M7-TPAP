//
//  SidebarView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/17/25.
//

import SwiftUI

struct SidebarView: View {
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
            
            //-TODO: #42이슈 브랜치에서 구현한거 연결필요
            //SegmentedContolView()
            Spacer()
        }
        .frame(width: 259)
        .frame(maxHeight: .infinity)
        .background(.gray.opacity(0.1))
        .transition(.move(edge: .leading))
    }
}

#Preview(traits: .landscapeLeft) {
    SidebarView()
//        .environmentObject(PlanManager())
//        .environmentObject(UtilPen())
}
