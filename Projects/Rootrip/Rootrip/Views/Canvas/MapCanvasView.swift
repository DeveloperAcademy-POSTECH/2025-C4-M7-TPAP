//
//  MapCanvasView.swift
//  Rootrip
//
//  Created by POS on 7/24/25.

import MapKit
import PencilKit
import SwiftUI

struct MapCanvasView: View {
    @ObservedObject var viewModel: MapViewModel

    @Binding var shouldCenterOnUser: Bool
    @Binding var isUtilPen: Bool
    @Binding var isCanvasActive: Bool
    @Binding var undoTrigger: Bool
    @Binding var redoTrigger: Bool
    @Binding var lineWidth: CGFloat

    @State var mapView = MKMapView()
    @State var drawing = PKDrawing()
    @State private var pageLock = false


    var body: some View {
        ZStack {
            // UtilPen이 정상작동하는 세계관
            //            MapView(mapView: $mapView)
            //                            .ignoresSafeArea()

            MapView(
                viewModel: viewModel,
                shouldCenterOnUser: $shouldCenterOnUser,
                mapView: $mapView
            )
            .ignoresSafeArea()

            if isCanvasActive {
                CanvasView(
                    drawing: $drawing,
                    isUtilPen: $isUtilPen,
                    isCanvasActive: $isCanvasActive,
                    mapView: $mapView,
                    undoTrigger: $undoTrigger,
                    redoTrigger: $redoTrigger,
                    lineWidth: $lineWidth
                )
                .background(Color.clear)
                .ignoresSafeArea()
            }
        }
        .overlay(
            VStack(spacing: -7) {
                /// 유틸펜 사용 토글 버튼
                Button(action: {
                    switch (isCanvasActive, isUtilPen) {
                    case (true, true):
                        print("canvas activate, utilpen activate")
                        isCanvasActive = false
                        isUtilPen = false
                        drawing = PKDrawing()
                    case (true, false):
                        print("canvas activate, utilpen deactivate")
                        isUtilPen = true
                    case (false, false):
                        print("canvas deactivate, utilpen deactivate")
                        isCanvasActive = true
                        isUtilPen = true
                        drawing = PKDrawing()
                    default:
                        print("canvas deactivate, utilpen activate")
                        break // logic error
                    }
                }) {
                    Image(isUtilPen ? "utilOn" : "utilOff")
                }
                /// 내위치로 가기 버튼
                Button(action: {
                    shouldCenterOnUser = true
                }) {
                    Image("myLocation")
                }
            }
            .padding(),
            alignment: .bottomTrailing
        )
        .onAppear {
            mapView.delegate = MapDelegate.shared
        }
    }
}

// TODO: pencil Toolbar의 값을 반영할 수 있도록 연동
class MapDelegate: NSObject, MKMapViewDelegate {
    static let shared = MapDelegate()
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay)
        -> MKOverlayRenderer
    {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            if let hex = polyline.title, let color = UIColor(hexString: hex) {
                renderer.strokeColor = color
            } else {
                renderer.strokeColor = .systemBlue  // 유틸펜의 기본색상 삽입
            }
            renderer.lineWidth = 4  // 선굵기값 받아오기
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

// Drawing Pen이 색을 유지할 수 있게
extension UIColor {
    convenience init?(hexString: String) {
        var cString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
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
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int =
            (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        return String(format: "#%06X", rgb)
    }
}
