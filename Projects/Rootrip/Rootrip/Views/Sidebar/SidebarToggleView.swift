//
//  ContentView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/17/25.
//

import SwiftUI

struct SidebarToggleView: View {
    @State private var showSidebar = true
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            MapCanvasToolPicker()
                .padding(.top, 50)
            
            if showSidebar {
                SidebarView()
            }
            
            VStack(spacing: 0) {
                MapCanvasToolBar(isSidebarOpen: $showSidebar)
                Spacer()
            }
            
        }
    }
}

#Preview(traits: .landscapeLeft) {
    SidebarToggleView()
        .environmentObject(PlanManager())
        .environmentObject(RouteManager())
}
