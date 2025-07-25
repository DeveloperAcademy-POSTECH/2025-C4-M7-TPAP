//
//  MapCanvasToolPicker.swift
//  Rootrip
//
//  Created by eunsoo on 7/25/25.
//

import SwiftUI

struct MapCanvasToolPicker: View {
    var body: some View {
        ZStack {
            HStack(spacing: 10){
                Spacer()
                
                PenThicknessSlider()
                    .padding(.trailing, 20)
                
                Button(action: {}) {
                    Image(systemName: "eraser")
                }
                //map위에 호버팅 버튼으로 빠질 예정이라 주석처리
//                Button(action: {}) {
//                    Image(systemName: "pencil.circle.fill")
//                }
                Button(action: {}) {
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
            Color.toolbarGray
        )
        
        
    }
}
