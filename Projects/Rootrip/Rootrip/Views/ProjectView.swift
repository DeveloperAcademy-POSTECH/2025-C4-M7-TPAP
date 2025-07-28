//
//  TestMapView.swift
//  RouteManagerTest
//
//  Created by POS on 7/12/25.
//

import CoreLocation
import MapKit
import SwiftUI

struct ProjectView: View {
    let project: Project
    @StateObject private var mapState = RouteManager()

    @EnvironmentObject var planManager: PlanManager

    @State private var hasLoadedPlans = false

    // MARK: - Body
    var body: some View {
        ZStack {
            MapCanvasView()

            // 사이드바 버튼 오버레이(추가함!)
            SidebarToggleView(project: project).environmentObject(mapState)
        }
        .onAppear {
            guard !hasLoadedPlans else { return }
            hasLoadedPlans = true

            guard let projectID = project.id else { return }

            Task {
                await planManager.loadPlans(for: projectID)
            }
        }

        .edgesIgnoringSafeArea(.all)
    }
}

//#Preview(traits: .landscapeLeft) {
//    ProjectView()
//        .environmentObject(RouteManager())
//        .environmentObject(PlanManager())
//        .environmentObject(BookmarkManager())
//}
