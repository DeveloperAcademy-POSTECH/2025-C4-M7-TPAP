import SwiftUI
import PencilKit
import MapKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - DrawingCanvasView (UIViewRepresentable)
struct DrawingCanvasView: UIViewRepresentable {
    let currentTool: PKTool
    let currentRegion: MKCoordinateRegion
    @Binding var isDrawing: Bool
    var mapView: MKMapView
    var onMappedCoordinates: (([CLLocationCoordinate2D]) -> Void)?
    var onDrawingChanged: ((PKDrawing) -> Void)?
    var onSaveDrawing: (([CLLocationCoordinate2D]) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - makeUIView
    func makeUIView(context: Context) -> PKCanvasView {
        let customCanvasView = DrawingCanvasViewInternal()
        customCanvasView.drawingPolicy = .pencilOnly
        customCanvasView.backgroundColor = .clear
        customCanvasView.tool = currentTool
        customCanvasView.onTouchTypeDetected = { touchType in
            if touchType == .direct {
                isDrawing = false
            }
        }
        customCanvasView.mapView = mapView
        customCanvasView.onMappedCoordinates = onMappedCoordinates
        customCanvasView.onSaveDrawing = onSaveDrawing
        customCanvasView.delegate = context.coordinator
        return customCanvasView
    }

    // MARK: - updateUIView
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = currentTool
        NotificationCenter.default.addObserver(forName: Notification.Name("UtilPenSelected"), object: nil, queue: .main) { _ in
            if let customView = uiView as? DrawingCanvasViewInternal {
                customView.isUtilPen = true
            }
        }
        NotificationCenter.default.addObserver(forName: Notification.Name("ApplyLoadedDrawing"), object: nil, queue: .main) { notification in

            if let dict = notification.object as? [String: Any],
               let coords = dict["coordinates"] as? [CLLocationCoordinate2D],
               let customView = uiView as? DrawingCanvasViewInternal,
               let mapView = customView.mapView {

                let centerCoord = mapView.centerCoordinate
                let centerPoint = mapView.convert(centerCoord, toPointTo: mapView)

                let strokePoints: [PKStrokePoint] = coords.map { coordinate in
                    let point = mapView.convert(coordinate, toPointTo: mapView)
                    let adjustedPoint = CGPoint(x: point.x - centerPoint.x, y: point.y - centerPoint.y)
                    return PKStrokePoint(location: adjustedPoint, timeOffset: 0, size: CGSize(width: 5, height: 5), opacity: 1, force: 1, azimuth: 0, altitude: 0)
                }

                if !strokePoints.isEmpty {
                    let path = PKStrokePath(controlPoints: strokePoints, creationDate: Date())
                    let stroke = PKStroke(ink: PKInk(.pen, color: .black), path: path)
                    uiView.drawing = PKDrawing(strokes: [stroke])
                    print("좌표 기반 드로잉 적용 완료, stroke count: \(uiView.drawing.strokes.count)")
                    return  // skip the fallback drawing logic
                } else {
                    print("strokePoints가 비어있어 드로잉 적용 생략")
                }
            }

            if let drawing = notification.object as? PKDrawing {
                uiView.drawing = drawing

                let filteredStrokes = drawing.strokes.filter { !$0.path.isEmpty }
                if filteredStrokes.isEmpty || drawing.bounds == .zero {
                    print("Detected empty or invalid strokes – cleaning up saved file if exists")
                    if let customView = uiView as? DrawingCanvasViewInternal,
                       let mapView = customView.mapView {
                        if let lastPoints = customView.lastDrawnCoordinateList,
                           let key = makeRegionKey(from: lastPoints) {

                            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                .appendingPathComponent("RootripDrawings/\(key).drawing")

                            let exists = FileManager.default.fileExists(atPath: fileURL.path)
                            print("Drawing file exists: \(exists)")

                            try? FileManager.default.removeItem(at: fileURL)
                            print("Removed saved file at: \(fileURL.path)")
                        }
                    }
                    uiView.drawing = PKDrawing() // ensure empty canvas is displayed
                    return
                }
            }
        }
    }
    
    func makeRegionKey(from coordinates: [CLLocationCoordinate2D]) -> String? {
        // Implement key generation logic based on coordinates or currentRegion
        // For example, use center coordinate of currentRegion
        let center = currentRegion.center
        return "region_\(center.latitude)_\(center.longitude)"
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingCanvasView

        init(_ parent: DrawingCanvasView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.onDrawingChanged?(canvasView.drawing)
        }
    }
}


// MARK: - Internal PKCanvasView Class
class DrawingCanvasViewInternal: PKCanvasView {
    var onTouchTypeDetected: ((UITouch.TouchType) -> Void)?
    var isDrawing: Bool = true
    var mapView: MKMapView?
    var onMappedCoordinates: (([CLLocationCoordinate2D]) -> Void)?
    var lastDrawnCoordinateList: [CLLocationCoordinate2D]?
    var isUtilPen: Bool = false
    var onSaveDrawing: (([CLLocationCoordinate2D]) -> Void)?

    // MARK: - touchesBegan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if isDrawing {
            if let touch = touches.first {
                onTouchTypeDetected?(touch.type)
            }
        }
    }

    // MARK: - touchesEnded and Drawing Save Logic
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let mapView = mapView else { return }

        var coordinateList: [CLLocationCoordinate2D] = []

        for stroke in drawing.strokes {
            for point in stroke.path.interpolatedPoints(by: .distance(1.0)) {
                let cgPoint = CGPoint(x: point.location.x, y: point.location.y)
                let adjustedPoint = self.convert(cgPoint, to: mapView)
                let coordinate = mapView.convert(adjustedPoint, toCoordinateFrom: mapView)
                coordinateList.append(coordinate)
            }
        }

        self.lastDrawnCoordinateList = coordinateList

        for coord in coordinateList {
            print("변환된 좌표: \(coord.latitude), \(coord.longitude)")
        }

        onSaveDrawing?(coordinateList)
        
        onMappedCoordinates?(coordinateList)
    }
}
