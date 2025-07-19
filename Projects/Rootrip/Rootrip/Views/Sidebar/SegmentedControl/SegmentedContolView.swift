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
    @State private var selectedIndex = 0
    @Namespace private var animation
    private let segments = ["일정", "보관함", "참여자"]

    var body: some View {
        // MARK: - Segment Selection
        HStack(spacing: -4) {
            ForEach(0..<segments.count, id: \.self) { index in
                ZStack {
                    //선택된 세그먼트
                    if selectedIndex == index {
                        RoundedRectangle(cornerRadius: 13)
                            .fill(Color.white)
                            .matchedGeometryEffect(id: "background", in: animation)
                            .frame(width: 47, height: 21)
                    }

                    Text(segments[index])
                        .font(.system(size: 12))
                        .foregroundColor(selectedIndex == index ? Color.purple : Color.gray)
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
        .frame(width: 151, height: 29)
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .padding(.vertical, 11)

        // MARK: - Child View Rendering (선택된 탭에 따른 하위 뷰 렌더링)
        Group {
            switch selectedIndex {
            case 0: PlanView()
            case 1: BookmarkView()// TODO: 북마크 뷰 구현 예정
            case 2: ParticipantsView()// TODO: 참여자 뷰 구현 예정
            default: EmptyView()
            }
        }
    }
}


#Preview {
    SegmentedContolView()
//        .environmentObject(PlanManager())
//        .environmentObject(UtilPen())
}
