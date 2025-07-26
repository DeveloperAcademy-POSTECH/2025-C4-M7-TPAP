//
//  SidebarView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/17/25.
//

import SwiftUI


struct SidebarView: View {
    var body: some View {
        ScrollView{
            HStack{
                Spacer()
                //MARK: - TODO: 편집 버튼 기능 연결 필요
                Button(action:{
                    
                }){
                    Text("편집")
                        .foregroundColor(.purple)
                        .font(.system(size: 16))
                }
            }
            .padding(.top, 10)
            .padding(.trailing, 16)
            
            SegmentedContolView()
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
}
