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
        print("[CanvasVC] viewDidLoad - isUtilPen = \(isUtilPen)")
    }

    private func setupCanvasView() {
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.delegate = self
        canvasView.backgroundColor = .clear
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
    
    // TODO: Toolbar 완성되면 이 부분 날리면됩니다
    private func setupToolbar() {
        toolbar.axis = .horizontal
        toolbar.alignment = .center
        toolbar.distribution = .equalSpacing
        toolbar.spacing = 24
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        undoButton.setImage(
            UIImage(systemName: "arrow.uturn.backward"),
            for: .normal
        )
        redoButton.setImage(
            UIImage(systemName: "arrow.uturn.forward"),
            for: .normal
        )
        eraserButton.setImage(UIImage(systemName: "eraser"), for: .normal)
        penButton.setImage(UIImage(systemName: "pencil.tip"), for: .normal)
        utilPenButton.setImage(UIImage(systemName: "map"), for: .normal)
        colorPicker.selectedColor = penColor
        colorPicker.supportsAlpha = false

        undoButton.addTarget(
            self,
            action: #selector(undoTapped),
            for: .touchUpInside
        )
        redoButton.addTarget(
            self,
            action: #selector(redoTapped),
            for: .touchUpInside
        )
        eraserButton.addTarget(
            self,
            action: #selector(eraserTapped),
            for: .touchUpInside
        )
        penButton.addTarget(
            self,
            action: #selector(penTapped),
            for: .touchUpInside
        )
        colorPicker.addTarget(
            self,
            action: #selector(colorChanged),
            for: .valueChanged
        )
        utilPenButton.addTarget(
            self,
            action: #selector(utilPenToggled),
            for: .touchUpInside
        )

        [
            undoButton, redoButton, eraserButton, penButton, utilPenButton,
            colorPicker,
        ].forEach { button in
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            toolbar.addArrangedSubview(button)
        }

        toolbar.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        toolbar.layer.cornerRadius = 18

        view.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 10
            ),
            toolbar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    // TODO: 임시 툴바 동작들. 실제 Toolbar와 연동해야함
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
            print(
                // utilPen → drawingPen 으로 변할 때
                "[CanvasVC] Switching utilPen → drawingPen, save & clear canvas!"
            )
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
            print(
                "[CanvasVC] Switching drawingPen → utilPen, save & clear canvas"
            )
            saveDrawing(canvasView.drawing)
            clearCanvas()
        }
        isUtilPen = true
        updatePenModeButtons()
        onUtilPenToggled?(isUtilPen)
    }
    
    func clearCanvas() {
        DispatchQueue.main.async {
            self.drawing = PKDrawing()
            self.canvasView.drawing = PKDrawing()
        }
    }

    func updatePenModeButtons() {
        penButton.tintColor = isUtilPen ? .systemGray : .systemBlue
        utilPenButton.tintColor = isUtilPen ? .systemBlue : .systemGray
    }

    // PencilKit Delegate (모든 입력에 대해 stroke 좌표 로그 & 처리)
    // 아니 이딴 이름이 MK 기본 메소드라니
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let strokes = canvasView.drawing.strokes
        guard let stroke = strokes.last else { return }

        print("PKStroke 입력됨 (utilPen: \(isUtilPen)) ---")
        for (ptIdx, pt) in stroke.path.enumerated() {
            print("   [\(ptIdx)] x:\(pt.location.x), y:\(pt.location.y)")
        }

        if let mapView = mapView {
            let cgPoints = stroke.path.map { $0.location }
            let coords: [CLLocationCoordinate2D] = cgPoints.map { point in
                let mapPoint = mapView.convert(point, from: canvasView)
                return mapView.convert(mapPoint, toCoordinateFrom: mapView)
            }
            if isUtilPen {
                onUtilPenInput?(coords)
                var prevDrawing = canvasView.drawing
                prevDrawing.strokes.removeLast()
                DispatchQueue.main.async {
                    self.drawing = prevDrawing
                    self.canvasView.drawing = prevDrawing
                }
            } else {
                let hex = penColor.hexString
                let polyline = MKPolyline(
                    coordinates: coords,
                    count: coords.count
                )
                polyline.title = hex
                DispatchQueue.main.async {
                    mapView.addOverlay(polyline)
                }
                drawing = canvasView.drawing
                onDrawingChanged?(drawing)
                saveDrawing(drawing)
            }
        }
    }

    func saveDrawing(_ drawing: PKDrawing) {
        for (idx, stroke) in drawing.strokes.enumerated() {
            print("PKStroke #\(idx) ---")
            for (ptIdx, pt) in stroke.path.enumerated() {
                print("   [\(ptIdx)] x:\(pt.location.x), y:\(pt.location.y)")
            }
        }
        do {
            let data = drawing.dataRepresentation()
            let url = getDocumentsDirectory().appendingPathComponent(
                "drawing.data"
            )
            try data.write(to: url)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[
            0
        ]
    }
}
