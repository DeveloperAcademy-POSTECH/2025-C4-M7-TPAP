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
    
    // 지우개아이콘 적용을 위한 임시 변수
    @State var isEraserActivate: Bool = false
    
    var body: some View {
        ZStack {
            HStack(spacing: 15) {
                Spacer()
                
                PenThicknessSlider(thickness: $lineWidth, lineWidthTrigger: $lineWidthTrigger)
//                    .padding(.trailing, 20)

                Button(action: {
                    isEraserActivate.toggle()
                }) {
                    Image(isEraserActivate ? "eraserOn" : "eraserOff")
                        .renderingMode(.original)
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
                }

                Button(action: {}) {
                    Image("colPic")
                        .renderingMode(.original)
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
