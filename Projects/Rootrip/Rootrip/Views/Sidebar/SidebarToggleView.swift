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
    @State private var pageLock: Bool = false

    @Binding var lineWidth: CGFloat
    @Binding var isUtilPen: Bool
    @Binding var isCanvasActive: Bool
    @Binding var isPageLocked: Bool
    @Binding var undoTrigger: Bool
    @Binding var redoTrigger: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            MapCanvasToolPicker(
                isUtilPen: $isUtilPen,
                isCanvasActive: $isCanvasActive,
                isPageLocked: $isPageLocked,
                lineWidth: $lineWidth
            )
            .padding(.top, 50)
            .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 4)

            /// 사이드바
            VStack(alignment: .leading, spacing: 0) {
                MapCanvasToolBar(
                    project: project,
                    isSidebarOpen: $showSidebar,
                    isCanvasActive: $isCanvasActive,
                    isPageLocked: $isPageLocked,
                    undoTrigger: $undoTrigger,
                    redoTrigger: $redoTrigger
                )

                HStack {
                    if showSidebar {
                        SidebarView(projectID: project.id!)
                            .frame(width: 221)
                            .padding(.leading, 20)
                            .padding(.trailing, 19)
                            .padding(.bottom, 86)
                            .background(
                                Color(red: 0.96, green: 0.96, blue: 0.96)
                                    .shadow(
                                        color: .black.opacity(0.25),
                                        radius: 2,
                                        x: 2,
                                        y: 0
                                    )
                            )
                            .ignoresSafeArea(edges: .bottom)
                    }
                    Spacer()
                }
            }

            /// 검색창
            VStack {
                HStack {
                    Spacer()
                    SearchBarToggleView(text: $searchText)
                        .padding(.trailing, 20)
                }
                .padding(.top, 120)  // 최상단에서 숫자만큼 아래에 위치하도록(하드코딩,,)
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
