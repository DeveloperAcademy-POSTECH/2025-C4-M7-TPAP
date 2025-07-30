//
//  SegmentedContolView.swift
//  Sidebar
//
//  Created by MINJEONG on 7/17/25.
//

import SwiftUI
/// 상단 탭(일정, 보관함, 참여자)을 선택할 수 있는 세그먼트 뷰입니다.
/// 선택된 탭에 따라 하위 콘텐츠 뷰가 전환됩니다.
struct SegmentedContolView: View {
    @Binding var selectedIndex: Int
    @Namespace private var animation
    private let segments = ["일정", "보관함", "참여자"]
    let projectID: String

    var body: some View {
        // MARK: - Segment Selection
        HStack(spacing: -4) {
            ForEach(0..<segments.count, id: \.self) { index in
                ZStack {
                    //선택된 세그먼트
                    if selectedIndex == index {
                        RoundedRectangle(cornerRadius: 13)
                            .fill(Color.secondary4)
                            .matchedGeometryEffect(id: "background", in: animation)
                            .padding(.horizontal, 4)
                            .frame(width: 70, height: 21)
                    }

                    Text(segments[index])
                        .font(.prebold12)
                        .foregroundColor(selectedIndex == index ? Color.accent3 : Color.secondary4.opacity(0.7))
                        .frame(height: 21)
                        .onTapGesture {
                            withAnimation(.default) {
                                selectedIndex = index
                            }
                        }
                }
                // 각 세그먼트가 HStack 내에서 균등한 너비를 가지도록 설정
                .frame(maxWidth: .infinity)
            }
        }
        //세그먼트 배경
        .frame(width: 214, height: 29)
        .background(Color.primary1)
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .padding(.vertical, 11)
        .padding(.bottom, 19)
    }
}
