//
//  CanvasView.swift
//  Rootrip
//
//  Created by POS on 7/24/25.
//

import SwiftUI
import PencilKit

struct CanvasView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CanvasViewController {
        let vc = CanvasViewController()
        return vc
    }
    func updateUIViewController(_ uiViewController: CanvasViewController, context: Context) {}
}

class CanvasViewController: UIViewController, PKCanvasViewDelegate {
    let canvasView = PKCanvasView()
    let toolbar = UIStackView()
    let undoButton = UIButton(type: .system)
    let redoButton = UIButton(type: .system)
    let eraserButton = UIButton(type: .system)
    let penButton = UIButton(type: .system)
    let colorPicker = UIColorWell()

    var undoStack: [PKDrawing] = []
    var redoStack: [PKDrawing] = []
    var penColor: UIColor = .black

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvasView()
        setupToolbar()
        if let loaded = loadDrawing() {
            canvasView.drawing = loaded
            undoStack = [loaded]
        } else {
            undoStack = [canvasView.drawing]
        }
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
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // TODO: 그냥 막 구현한 툴바. 전면수정 부탁드립니다
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
        colorPicker.selectedColor = penColor
        colorPicker.supportsAlpha = false

        undoButton.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        redoButton.addTarget(self, action: #selector(redoTapped), for: .touchUpInside)
        eraserButton.addTarget(self, action: #selector(eraserTapped), for: .touchUpInside)
        penButton.addTarget(self, action: #selector(penTapped), for: .touchUpInside)
        colorPicker.addTarget(self, action: #selector(colorChanged), for: .valueChanged)

        [undoButton, redoButton, eraserButton, penButton, colorPicker].forEach { button in
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            toolbar.addArrangedSubview(button)
        }

        toolbar.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        toolbar.layer.cornerRadius = 18

        view.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            toolbar.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // TODO: connected toolbar functions. MainViewToolBar랑 연동시켜야함
    @objc func undoTapped() {
        canvasView.undoManager?.undo()
        saveDrawing(canvasView.drawing)
    }
    @objc func redoTapped() {
        canvasView.undoManager?.redo()
        saveDrawing(canvasView.drawing)
    }
    @objc func eraserTapped() {
        canvasView.tool = PKEraserTool(.vector)
    }
    @objc func penTapped() {
        canvasView.tool = PKInkingTool(.pen, color: penColor, width: 5)
    }
    @objc func colorChanged() {
        if let selected = colorPicker.selectedColor {
            penColor = selected
            if canvasView.tool is PKInkingTool {
                canvasView.tool = PKInkingTool(.pen, color: penColor, width: 5)
            }
        }
    }

    /// 이름이 상당히 못생겼지만 PK 공식 메서드라 써야댐..
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        saveDrawing(canvasView.drawing)
    }

    // data management(local)
    func saveDrawing(_ drawing: PKDrawing) {
        for (idx, stroke) in drawing.strokes.enumerated() {
            print("PKStroke #\(idx) ---")
            for (ptIdx, pt) in stroke.path.enumerated() {
                print("   [\(ptIdx)] x:\(pt.location.x), y:\(pt.location.y)")
            }
        }
        do {
            let data = drawing.dataRepresentation()
            let url = getDocumentsDirectory().appendingPathComponent("drawing.data")
            try data.write(to: url)
        } catch {
            print("Error saving data: \(error)")
        }
    }

    func loadDrawing() -> PKDrawing? {
        let url = getDocumentsDirectory().appendingPathComponent("drawing.data")
        if let data = try? Data(contentsOf: url) {
            return try? PKDrawing(data: data)
        }
        return nil
    }
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
