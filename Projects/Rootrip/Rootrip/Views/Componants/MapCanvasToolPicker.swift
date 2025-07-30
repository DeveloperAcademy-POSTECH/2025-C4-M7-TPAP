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
    @Binding var lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            HStack(spacing: 10){
                Spacer()
                
                //MARK: - 펜 굵기 확인하는 임시 뷰
                Text("pen width: \(lineWidth)")
                    .padding(.trailing, 10)
                    .foregroundStyle(.gray)
                
                PenThicknessSlider(thickness: $lineWidth)
                    .padding(.trailing, 20)
                
                Button(action: {}) {
                    Image(systemName: "eraser")
                }
                //map위에 호버팅 버튼으로 빠질 예정이라 주석처리
//                Button(action: {}) {
//                    Image(systemName: "pencil.circle.fill")
//                }
                Button(action: {
                    isCanvasActive.toggle()
                    isUtilPen = false
                }) {
                    Image(systemName: "pencil.tip.crop.circle.fill")
                }
                Button(action: {}) {
                    Image(systemName: "paintpalette")
                }
                    .padding(.trailing, 50)
            }
            .foregroundStyle(Color.black)
            
        }
        .frame(height: 50) // 툴바 콘텐츠의 높이 지정
        .background(
            Color.mainbackground
        )
        
        
    }
}


//#Preview {
//    MapCanvasToolPicker()
//}
