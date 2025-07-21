//
//  ContentView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/17/25.
//

import SwiftUI
//TODO: -MainViewToolbar에 해당 버튼 포함시켜야함
///사이드바 위에 툴바가 올라오도록 한 화면입니다.(사이드바는 기본 열림 상태)
struct SidebarToggleView: View {
    @State private var showSidebar = true
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            if showSidebar {
                SidebarView()
            }
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        withAnimation {
                            showSidebar.toggle()
                        }
                    }) {
                        Image(systemName: "sidebar.left")
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                //툴바 UI 확인상 넣어둠
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color.purple)
                
                Spacer()
            }
        }
    }
}

//#Preview(traits: .landscapeLeft) {
//    SidebarToggleView()
//        .environmentObject(PlanManager())
//        .environmentObject(UtilPen())
//}
