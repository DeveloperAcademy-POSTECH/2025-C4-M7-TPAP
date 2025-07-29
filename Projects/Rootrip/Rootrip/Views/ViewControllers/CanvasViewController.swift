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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvasView()
        setupToolbar()
        canvasView.drawing = drawing
        updatePenModeButtons()
    }

    private func setupCanvasView() {
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.delegate = self
        canvasView.drawingPolicy = .pencilOnly
        canvasView.tool = PKInkingTool(.pen, color: penColor, width: 5)
        canvasView.isOpaque = false
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupToolbar() {
        toolbar.axis = .horizontal
        toolbar.alignment = .center
        toolbar.distribution = .equalSpacing
        toolbar.spacing = 24
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        undoButton.setImage(UIImage(systemName: "arrow.uturn.backward"), for: .normal)
        redoButton.setImage(UIImage(systemName: "arrow.uturn.forward"), for: .normal)
        eraserButton.setImage(UIImage(systemName: "eraser"), for: .normal)
        penButton.setImage(UIImage(systemName: "pencil.tip"), for: .normal)
        utilPenButton.setImage(UIImage(systemName: "map"), for: .normal)
        colorPicker.selectedColor = penColor
        colorPicker.supportsAlpha = false

        undoButton.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        redoButton.addTarget(self, action: #selector(redoTapped), for: .touchUpInside)
        eraserButton.addTarget(self, action: #selector(eraserTapped), for: .touchUpInside)
        penButton.addTarget(self, action: #selector(penTapped), for: .touchUpInside)
        colorPicker.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
        utilPenButton.addTarget(self, action: #selector(utilPenToggled), for: .touchUpInside)

        [undoButton, redoButton, eraserButton, penButton, utilPenButton, colorPicker].forEach { button in
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            toolbar.addArrangedSubview(button)
        }

        toolbar.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        toolbar.layer.cornerRadius = 18

        view.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            toolbar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc func undoTapped() { canvasView.undoManager?.undo() }
    @objc func redoTapped() { canvasView.undoManager?.redo() }
    @objc func eraserTapped() { canvasView.tool = PKEraserTool(.vector) }
    @objc func colorChanged() {
        if let selected = colorPicker.selectedColor {
            penColor = selected
            if !isUtilPen {
                canvasView.tool = PKInkingTool(.pen, color: penColor, width: 5)
            }
        }
    }
    @objc func penTapped() {
        if isUtilPen {
            saveDrawing(canvasView.drawing)
            clearCanvas()
        }
        isUtilPen = false
        updatePenModeButtons()
        canvasView.tool = PKInkingTool(.pen, color: penColor, width: 5)
        onUtilPenToggled?(isUtilPen)
    }
    @objc func utilPenToggled() {
        if !isUtilPen {
            saveDrawing(canvasView.drawing)
            clearCanvas()
        }
        isUtilPen = true
        updatePenModeButtons()
        onUtilPenToggled?(isUtilPen)
    }
    func updatePenModeButtons() {
        penButton.tintColor = isUtilPen ? .systemGray : .systemBlue
        utilPenButton.tintColor = isUtilPen ? .systemBlue : .systemGray
    }
    func clearCanvas() {
        DispatchQueue.main.async {
            self.drawing = PKDrawing()
            self.canvasView.drawing = PKDrawing()
        }
    }

    // 드로잉 중 겹치는 점이 있는가. 근데 직선이랑 구분이 안됨 대체왜그러는거임 나한테
//    func hasOverlappingPoint(_ points: [CGPoint]) -> Bool {
//        let threshold: CGFloat = 3
//        for i in 0..<points.count {
//            for j in (i+1)..<points.count {
//                let dx = points[i].x - points[j].x
//                let dy = points[i].y - points[j].y
//                if sqrt(dx*dx + dy*dy) < threshold {
//                    print("--- overlapped point detected ---")
//                    return true
//                }
//            }
//        }
//        return false
//    }

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
