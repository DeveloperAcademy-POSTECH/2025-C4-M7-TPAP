//
//  ContentView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/17/25.
//

import SwiftUI

// 사이드바 위에 툴바가 올라오도록 한 화면입니다.(사이드바는 기본 열림 상태)
struct SidebarToggleView: View {
    let project: Project
    @State private var showSidebar = true
    @State private var searchText = ""

    var body: some View {
        ZStack(alignment: .topLeading) {
            MapCanvasToolPicker()
                .padding(.top, 50)
            
            /// 사이드바
            VStack(alignment: .leading, spacing: 0) {
                MapCanvasToolBar(project: project, isSidebarOpen: $showSidebar)

                HStack {
                    if showSidebar {
                        SidebarView(projectID: project.id!)
                            .ignoresSafeArea(edges: .bottom)
                    }
                    Spacer()
                }
            }
            
            /// 검색창
            VStack(){
                HStack {
                    Spacer()
                    searchBar(text: $searchText) {
                        print("검색 실행: \(searchText)")
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 120) // 최상단에서 숫자만큼 아래에 위치하도록(하드코딩,,)
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
