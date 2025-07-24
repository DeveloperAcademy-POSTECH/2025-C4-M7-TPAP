//
//  MapCanvasView.swift
//  Rootrip
//
//  Created by POS on 7/24/25.
//

import SwiftUI
import PencilKit

struct MapCanvasView: View {
    @State private var isActivate = false
    @State private var drawing = PKDrawing()

    var body: some View {
        ZStack {
            MapView()

            if isActivate {
                CanvasView(drawing: $drawing)
                    .background(Color.clear)
                    .ignoresSafeArea()
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isActivate.toggle()
                    }) {
                        Text(isActivate ? "TO MAP" : "TO CANVAS")
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
