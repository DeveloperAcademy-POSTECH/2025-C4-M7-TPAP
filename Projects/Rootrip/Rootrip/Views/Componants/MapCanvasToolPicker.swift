//
//  MapCanvasToolPicker.swift
//  Rootrip
//
//  Created by eunsoo on 7/25/25.
//

import SwiftUI

struct MapCanvasToolPicker: View {
    @Binding var isUtilPen: Bool
    @Binding var isCanvasActive: Bool
    @Binding var isPageLocked: Bool
    @Binding var lineWidth: CGFloat
    @Binding var lineWidthTrigger: Bool
    
    @State var isDrawing: Bool = false
    
    var body: some View {
        ZStack {
            HStack(spacing: 10) {
                Spacer()

                //MARK: - 펜 굵기 확인하는 임시 뷰
                Text("pen width: \(lineWidth)")
                    .padding(.trailing, 10)
                    .foregroundStyle(.gray)

                PenThicknessSlider(thickness: $lineWidth, lineWidthTrigger: $lineWidthTrigger)
                    .padding(.trailing, 20)

                Button(action: {}) {
                    Image(systemName: "eraser")
                }

                Button(action: {
                    guard !isPageLocked else {
                        return
                    }

                    if isCanvasActive && !isUtilPen {
                        isCanvasActive = false
                    } else if !isCanvasActive && !isUtilPen {
                        isCanvasActive = true
                    } else if isCanvasActive && isUtilPen {
                        isUtilPen = false
                    }
                }) {
                    Image((isCanvasActive && !isUtilPen) ? "penOn" : "penOff")
                        .renderingMode(.original)
//                     isDrawing.toggle()
//                     isCanvasActive.toggle()
//                     isUtilPen = false
//                 }) {
//                     Image(systemName: "pencil.tip.crop.circle.fill")
//                         .foregroundStyle(isDrawing ? Color.green : Color.black)
                }

                Button(action: {}) {
                    Image(systemName: "paintpalette")
                }
                .padding(.trailing, 50)
            }
            .foregroundStyle(Color.black)

        }
        .frame(height: 50)  // 툴바 콘텐츠의 높이 지정
        .background(
            Color.mainbackground
        )

    }
}

//#Preview {
//    MapCanvasToolPicker()
//}
