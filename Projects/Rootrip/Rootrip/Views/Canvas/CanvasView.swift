//
//  CanvasView.swift
//  Rootrip
//
//  Created by POS on 7/24/25.
//
import SwiftUI
import PencilKit
import MapKit

struct CanvasView: UIViewControllerRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var isUtilPen: Bool
    var mapView: MKMapView

    func makeUIViewController(context: Context) -> CanvasViewController {
        let vc = CanvasViewController()
        vc.drawing = drawing
        vc.isUtilPen = isUtilPen
        vc.mapView = mapView
        vc.onDrawingChanged = { updated in
            DispatchQueue.main.async {
                self.drawing = updated
            }
        }
        vc.onUtilPenInput = { coords in
            let polyline = MKPolyline(coordinates: coords, count: coords.count)
            DispatchQueue.main.async {
                mapView.addOverlay(polyline)
            }
        }
        vc.onUtilPenToggled = { state in
            DispatchQueue.main.async {
                self.isUtilPen = state
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: CanvasViewController, context: Context) {
        uiViewController.drawing = drawing
        uiViewController.isUtilPen = isUtilPen
        uiViewController.updatePenModeButtons()
    }
}
