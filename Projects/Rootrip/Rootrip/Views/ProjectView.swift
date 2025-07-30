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
    @EnvironmentObject  var mapState: LocationManager
    @EnvironmentObject var planManager: PlanManager

    @StateObject private var viewModel = MapViewModel()
    

    @State private var hasLoadedPlans = false
    @State private var shouldCenterOnUser = false
    
    @State var isUtilPen = true
    @State var isCanvasActive = false
    @State var undoTrigger: Bool = false
    @State var redoTrigger: Bool = false
    @State var lineWidthTrigger: Bool = false
    @State var lineWidth:CGFloat = 8.0

    // MARK: - Body
    var body: some View {
        ZStack {
            MapCanvasView(
                viewModel: viewModel,
                shouldCenterOnUser: $shouldCenterOnUser,
                isUtilPen: $isUtilPen,
                isCanvasActive: $isCanvasActive,
                undoTrigger: $undoTrigger,
                redoTrigger: $redoTrigger,
                lineWidth: $lineWidth,
                lineWidthTrigger: $lineWidthTrigger
            )

            // 사이드바 버튼 오버레이(추가함!)
            SidebarToggleView(
                project: project,
                lineWidth: $lineWidth,
                isUtilPen: $isUtilPen,
                isCanvasActive: $isCanvasActive,
                undoTrigger: $undoTrigger,
                redoTrigger: $redoTrigger,
                lineWidthTrigger: $lineWidthTrigger
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
