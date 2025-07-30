//
//  CanvasViewController.swift
//  Rootrip
//
//  Created by POS on 7/24/25.
//

import MapKit
import PencilKit
import UIKit

class CanvasViewController: UIViewController, PKCanvasViewDelegate {
    let UtilPenState = UtilPen()

    let canvasView = PKCanvasView()
    let toolbar = UIStackView()
    let undoButton = UIButton(type: .system)
    let redoButton = UIButton(type: .system)
    let eraserButton = UIButton(type: .system)
    let penButton = UIButton(type: .system)
    let colorPicker = UIColorWell()
    let utilPenButton = UIButton(type: .system)

    var penColor: UIColor = .black
    var isUtilPen: Bool = false
    var mapView: MKMapView?
    var drawing: PKDrawing = PKDrawing()
    var onDrawingChanged: ((PKDrawing) -> Void)?
    var onUtilPenInput: (([CLLocationCoordinate2D]) -> Void)?
    var onUtilPenToggled: ((Bool) -> Void)?
    
    var tmpPolyline: [MKPolyline] = []
    
    var lineWidth: CGFloat = 8.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvasView()
        canvasView.drawing = drawing
    }

    private func setupCanvasView() {
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.delegate = self
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .pencilOnly
        canvasView.tool = PKInkingTool(.pen, color: penColor, width: lineWidth)
        canvasView.isOpaque = false
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    //canvasview비활성화 상태일때는 동작 안함
    @objc func undoTapped() {
        guard let mv = mapView else {
            print("map view error")
            return
        }
        guard let lastOverlay = mv.overlays.last else {
            print("no overlays to undo")
            return
        }
        
        guard let polyline = lastOverlay as? MKPolyline else {
            print("last overlay is not MKPolyline")
            return
        }
        
        print("undo tapped")
        // tmpPolyline에 추가 (redo를 위해)
        tmpPolyline.append(polyline)
        print("tmpPolyline added: \(tmpPolyline.count) items")
        
        mv.removeOverlay(lastOverlay)
    }
    //리두 작동안함
    @objc func redoTapped() {
        guard let mv = mapView else {
            print("map view error")
            return
        }
        
        guard !tmpPolyline.isEmpty else {
            print("redo 할 수 있는 스트로크가 없습니다.")
            return
        }
        
        guard let lastPolyline = tmpPolyline.last else {
            print("[redo] : tmpPolyline.last error")
            return
        }
        
        print("redo tapped - restoring polyline")
        mv.addOverlay(lastPolyline)
        tmpPolyline.removeLast()
        print("tmpPolyline remaining: \(tmpPolyline.count) items")
    }
    @objc func linewidthSliderValueChanged() {
        canvasView.tool = PKInkingTool(.pen, color: penColor, width: lineWidth)
    }

    
    @objc func eraserTapped() { canvasView.tool = PKEraserTool(.vector) }
    @objc func colorChanged() {
        if let selected = colorPicker.selectedColor {
            penColor = selected
            if !isUtilPen {
                canvasView.tool = PKInkingTool(.pen, color: penColor, width: lineWidth)
            }
        }
    }
    @objc func penTapped() {
        if isUtilPen {
            saveDrawing(canvasView.drawing)
            clearCanvas()
        }
        isUtilPen = false
        canvasView.tool = PKInkingTool(.pen, color: penColor, width: lineWidth)
        onUtilPenToggled?(isUtilPen)
    }
    @objc func utilPenToggled() {
        if !isUtilPen {
            saveDrawing(canvasView.drawing)
            clearCanvas()
        }
        isUtilPen = true
        onUtilPenToggled?(isUtilPen)
    }

    func clearCanvas() {
        DispatchQueue.main.async {
            self.drawing = PKDrawing()
            self.canvasView.drawing = PKDrawing()
        }
    }

    // 시작점과 끝점 거리가 가까운가
    func isClosedShape(points: [CGPoint]) -> Bool {
        let threshold: CGFloat = 100
        guard let first = points.first, let last = points.last, points.count >= 3 else { return false }
        let dx = first.x - last.x
        let dy = first.y - last.y
        print("--- distance between stt, end: \(sqrt(dx*dx + dy*dy)) ---")
        return sqrt(dx*dx + dy*dy) < threshold
    }

    // PencilKit Delegate
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        guard let stroke = canvasView.drawing.strokes.last,
              let mapView = mapView else { return }
        let cgPoints = stroke.path.map { $0.location }
        let isArea = isClosedShape(points: cgPoints) /*|| hasOverlappingPoint(cgPoints)*/
        let coords: [CLLocationCoordinate2D] = cgPoints.map { point in
            let mapPoint = mapView.convert(point, from: canvasView)
            return mapView.convert(mapPoint, toCoordinateFrom: mapView)
        }

        print("PKStroke 입력됨 (utilPen: \(isUtilPen)) ---")
        for (ptIdx, pt) in stroke.path.enumerated() {
            print("   [\(ptIdx)] x:\(pt.location.x), y:\(pt.location.y)")
        }

        if isUtilPen {
            if isArea {
                UtilPenState.areaHandler(coords, mapView: mapView)
            } else {
                UtilPenState.lineHandler(coords, mapView: mapView)
            }
            var prevDrawing = canvasView.drawing
            prevDrawing.strokes.removeLast()
            DispatchQueue.main.async {
                self.drawing = prevDrawing
                self.canvasView.drawing = prevDrawing
            }
        } else {
            let hex = penColor.hexString
            let polyline = MKPolyline(coordinates: coords, count: coords.count)
            polyline.title = hex
            DispatchQueue.main.async {
                mapView.addOverlay(polyline)
            }
            drawing = canvasView.drawing
            onDrawingChanged?(drawing)
            saveDrawing(drawing)
        }
    }

    
    func saveDrawing(_ drawing: PKDrawing) {
        /// 디버깅용 콘솔에 좌표찍기
        for (idx, stroke) in drawing.strokes.enumerated() {
            print("PKStroke #\(idx) ---")
            for (ptIdx, pt) in stroke.path.enumerated() {
                print("   [\(ptIdx)] x:\(pt.location.x), y:\(pt.location.y)")
            }
        }
        
        // TODO: overlay 객체를 저장하는 데이터타입이 필요합니다.
        // Stack 혹은 배열 등 형태가 좋을듯합니다?
        // Attribute: PenType: 드로잉인지 유틸인지, ID: eraser의 target을 찾기 위해, UtilType: 유틸펜이면 Area? Route? 루트면 하나만 표시되면 되니까 이전걸 삭제, Color: 드로잉펜의 경우 색상 저장, Width: 드로잉이면 선굵기
        do {
            let data = drawing.dataRepresentation()
            let url = getDocumentsDirectory().appendingPathComponent("drawing.data")
            try data.write(to: url)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
