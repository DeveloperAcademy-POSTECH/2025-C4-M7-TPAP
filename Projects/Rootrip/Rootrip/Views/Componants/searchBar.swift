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
        VStack(alignment: .leading, spacing: 10){
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

#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""

        var body: some View {
            searchBar(text: $text) {
                print("검색 실행: \(text)")
            }
        }
    }

    return PreviewWrapper()
}
