//
//  TestMapView.swift
//  RouteManagerTest
//
//  Created by POS on 7/12/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct ProjectView: View {
    let project: Project
    @StateObject private var mapState = RouteManager()
    
    // MARK: - Body
    var body: some View {
        Text("projectID: \(project.id)") // debugging line
        ZStack {
            /// 지도
//            RouteMapRepresentable(mapState: mapState)
            MapCanvasView()
            
            // 사이드바 버튼 오버레이(추가함!)
            SidebarToggleView().environmentObject(mapState)
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
