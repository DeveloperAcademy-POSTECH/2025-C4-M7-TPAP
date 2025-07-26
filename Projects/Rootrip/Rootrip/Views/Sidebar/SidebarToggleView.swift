//
//  ContentView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/17/25.
//

import SwiftUI

// 사이드바 위에 툴바가 올라오도록 한 화면입니다.(사이드바는 기본 열림 상태)
struct SidebarToggleView: View {
    @State private var showSidebar = true
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            MapCanvasToolPicker()
                .padding(.top, 50)
            
            VStack(alignment: .leading, spacing: 0) {
                MapCanvasToolBar(isSidebarOpen: $showSidebar)
                
                if showSidebar {
                    SidebarView()
                        .ignoresSafeArea(edges: .bottom)
                }
                Spacer()
            }
        }
    }
}

//#Preview(traits: .landscapeLeft) {
//    SidebarToggleView()
//        .environmentObject(PlanManager())
//        .environmentObject(LocationManager())
//}
