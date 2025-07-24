//
//  MapCanvasView.swift
//  Rootrip
//
//  Created by POS on 7/24/25.
//

import MapKit
import SwiftUI

struct MapCanvasView: View {
    @State private var isCanvasActive = false
    @State private var mapView = MKMapView()

    var body: some View {
        ZStack {
            MapView(mapView: $mapView)

            CanvasView()
                .opacity(isCanvasActive ? 1 : 0)
                .allowsHitTesting(isCanvasActive)
                .background(Color.clear)
                .ignoresSafeArea()
        }
        .overlay(
            // TODO: 입력기 전환은 일단은 버튼으로 해보실게요..
            Button(action: {
                isCanvasActive.toggle()
            }) {
                Text(isCanvasActive ? "TO MAP" : "TO CANVAS")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
            .padding(),
            alignment: .topTrailing
        )
    }
}
