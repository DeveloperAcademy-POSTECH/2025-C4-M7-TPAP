//
//  searchBar.swift
//  Rootrip
//
//  Created by POS on 7/29/25.
//
import Foundation
import SwiftUI

// 임시로 만들어둔 검색창(No 기능 only 타이핑)
struct searchBar: View {
    @Binding var text: String
    var onCommit: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)

                TextField("지도 검색", text: $text, onCommit: onCommit)
                    .foregroundColor(.primary)
                    .padding(.vertical, 10)

                // 검색내용 한 번에 지우기 만들어 말어?
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                }
            }
            .foregroundColor(.clear)
            .frame(width: 303, height: 36)
            .background(.secondary3)
            .cornerRadius(8)
        }
        .padding(11)
        .frame(width: 326, height: 59, alignment: .topLeading)
        .background(.mainbackground)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 0)
    }
}

// 검색창을 축소해두기 위한 토글
struct SearchBarToggleView: View {
    @Binding var text: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading) {
            if isExpanded {
                searchBar(text: $text)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width > 50 {
                                    withAnimation {
                                        isExpanded = false
                                    }
                                }
                            }
                    )
            } else {
                Button(action: {
                    withAnimation {
                        isExpanded = true
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.96, green: 0.96, blue: 0.96))

                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary2)
                            .font(Font.custom("SF Pro", size: 20))
                    }
                    .frame(width: 59, height: 48)
                    .shadow(
                        color: .black.opacity(0.25),
                        radius: 5,
                        x: 0,
                        y: 4
                    )
                }
                .transition(.scale)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""

        var body: some View {
            SearchBarToggleView(text: $text)
        }
    }

    return PreviewWrapper()
}
