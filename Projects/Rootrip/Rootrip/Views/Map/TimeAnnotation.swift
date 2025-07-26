//
//  WalkingTimeCalloutView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/18/25.
//

import SwiftUI
///커스텀된 말풍선 형태의 도보 소요시간을 나타내는 어노테이션입니다.
struct TimeAnnotation: View {
    let timeText: String
    
    var body: some View {
        VStack(spacing: 0){
            //네모 모양안에 도보 표시
            ZStack{
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray)
                    .frame(width: 108, height: 40)
                HStack(spacing: 35) {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.black)
                    Text(timeText)
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                }
                .foregroundColor(.black)
                .frame(width: 96, height: 29)
                .background(.white)
                .cornerRadius(8)
            }
            //역삼각형 합쳐서 말풍선 구현
            InvertedTriangle()
                .fill(Color.gray)
                .frame(width: 18, height: 12)
            
        }
    }
}
struct InvertedTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
}

//#Preview {
//    TimeAnnotation(timeText: "2m")
//}
