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
    @StateObject private var mapState = LocationManager()
    @StateObject private var viewModel = MapViewModel()

    @EnvironmentObject var planManager: PlanManager

    @State private var hasLoadedPlans = false
    @State private var shouldCenterOnUser = false
    
    @State var isUtilPen = false
    @State var isCanvasActive = false
    @State var isPageLocked: Bool = false
    @State var undoTrigger: Bool = false
    @State var redoTrigger: Bool = false
    @State var lineWidth: CGFloat = 8.0

    // MARK: - Body
    var body: some View {
        ZStack {
            MapCanvasView(
                viewModel: viewModel,
                shouldCenterOnUser: $shouldCenterOnUser,
                isUtilPen: $isUtilPen,
                isCanvasActive: $isCanvasActive,
                isPageLocked: $isPageLocked,
                undoTrigger: $undoTrigger,
                redoTrigger: $redoTrigger,
                lineWidth: $lineWidth
            )

            // 사이드바 버튼 오버레이(추가함!)
            SidebarToggleView(
                project: project,
                lineWidth: $lineWidth,
                isUtilPen: $isUtilPen,
                isCanvasActive: $isCanvasActive,
                isPageLocked: $isPageLocked,
                undoTrigger: $undoTrigger,
                redoTrigger: $redoTrigger
            )
            .environmentObject(mapState)
        }
        .onAppear {
            guard !hasLoadedPlans else { return }
            hasLoadedPlans = true

            guard let projectID = project.id else { return }

            Task {
                await planManager.loadPlans(for: projectID)
            }
        }
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
}

//#Preview(traits: .landscapeLeft) {
//    ProjectView()
//        .environmentObject(RouteManager())
//        .environmentObject(PlanManager())
//        .environmentObject(BookmarkManager())
//}
