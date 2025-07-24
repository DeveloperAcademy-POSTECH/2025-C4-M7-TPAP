//
//  MapCanvasView.swift
//  Rootrip
//
//  Created by POS on 7/24/25.

import SwiftUI
import MapKit
import PencilKit

struct MapCanvasView: View {
    @State private var isCanvasActive = false
    @State private var mapView = MKMapView()
    @State private var drawing = PKDrawing()
    @State private var isUtilPen = false

    var body: some View {
        ZStack {
            MapView(mapView: $mapView)
                .ignoresSafeArea()

            if isCanvasActive {
                CanvasView(
                    drawing: $drawing,
                    isUtilPen: $isUtilPen,
                    mapView: mapView
                )
                .background(Color.clear)
                .ignoresSafeArea()
            }
        }
        .overlay(
            Button(action: {
                isCanvasActive.toggle()
                print("[MapCanvasView] CanvasActive: \(isCanvasActive)")
            }) {
                Text(isCanvasActive ? "TO MAP" : "TO CANVAS")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
            .padding(),
            alignment: .topTrailing
        )
        .onAppear {
            mapView.delegate = MapDelegate.shared
        }
    }
}

// TODO: pencil Toolbar의 값을 반영할 수 있도록 연동
class MapDelegate: NSObject, MKMapViewDelegate {
    static let shared = MapDelegate()
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            if let hex = polyline.title, let color = UIColor(hexString: hex) {
                renderer.strokeColor = color
            } else {
                renderer.strokeColor = .systemBlue // 유틸펜의 기본색상 삽입
            }
            renderer.lineWidth = 4 // 선굵기값 받아오기
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

// Drawing Pen이 색을 유지할 수 있게
extension UIColor {
    convenience init?(hexString: String) {
        var cString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.removeFirst() }
        guard cString.count == 6 else { return nil }
        var rgb: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgb)
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    var hexString: String {
        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06X", rgb)
    }
}

