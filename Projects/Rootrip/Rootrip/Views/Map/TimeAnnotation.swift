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
                    .fill(Color.accent1.opacity(0.5))
                    .frame(width: 100, height: 45)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accent1, lineWidth: 1)
                    )
                HStack(spacing: 9) {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.accent1)
                    Text(timeText)
                        .font(.presemi12)
                        .foregroundColor(.accent1)
                }
                .foregroundColor(.accent1)
                .frame(width: 78, height: 29)
                .background(.secondary4)
                .cornerRadius(8)
            }
        }
    }
}

//#Preview {
//    TimeAnnotation(timeText: "2m")
//}
