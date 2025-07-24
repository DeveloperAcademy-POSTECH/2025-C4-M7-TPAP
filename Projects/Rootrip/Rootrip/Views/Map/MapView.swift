//
//  MapView.swift
//  Rootrip
//
//  Created by POS on 7/24/25.
//

//import SwiftUI
//import MapKit
//
//// TODO: 임의로 넣어둔 view임. #112에 따라 수정 필요

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var mapView: MKMapView

    func makeUIView(context: Context) -> MKMapView {
        // 유킷기반으로 넣어주세요
        mapView
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}
