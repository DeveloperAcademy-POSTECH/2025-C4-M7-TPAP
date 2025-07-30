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
    @Binding var isCanvasActive: Bool
    @Binding var mapView: MKMapView
    @Binding var undoTrigger: Bool 
    @Binding var redoTrigger: Bool
    @Binding var lineWidth: CGFloat
    @Binding var lineWidthTrigger: Bool

    func makeUIViewController(context: Context) -> CanvasViewController {
        let vc = CanvasViewController()
        vc.lineWidth = lineWidth
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
        uiViewController.lineWidth = lineWidth

        if undoTrigger {
            uiViewController.undoTapped()
            DispatchQueue.main.async {
                self.undoTrigger = false // Reset the trigger
            }
        }
        
        if redoTrigger {
            uiViewController.redoTapped()
            DispatchQueue.main.async {
                self.redoTrigger = false // Reset the trigger
            }
        }
        
        if lineWidthTrigger{
            uiViewController.lineWidth = lineWidth
            uiViewController.linewidthSliderValueChanged()
            DispatchQueue.main.async {
                self.lineWidthTrigger = false // Reset the trigger
            }
        }
        
        if isCanvasActive{
            uiViewController.clearCanvas()
        }
    }
}
