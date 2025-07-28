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
    @StateObject private var mapState = LocationManager()
    @State private var shouldCenterOnUser = false
    @StateObject private var viewModel = MapViewModel()
    
    // MARK: - Body
    var body: some View {
        ZStack {
            ZStack {
                /// 지도
                MapCanvasView(viewModel: viewModel, shouldCenterOnUser: $shouldCenterOnUser)
                // 사이드바 버튼 오버레이(추가함!)
                SidebarToggleView().environmentObject(mapState)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CenterLocationButton {
                        shouldCenterOnUser = true
                    }
                    .padding()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
}


//#Preview(traits: .landscapeLeft) {
//    ProjectView()
//        .environmentObject(LocationManager())
//        .environmentObject(PlanManager())
//}
