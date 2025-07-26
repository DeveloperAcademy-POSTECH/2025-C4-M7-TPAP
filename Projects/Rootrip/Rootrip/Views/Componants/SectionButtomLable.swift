//
//  SectionButtomLable.swift
//  Rootrip
//
//  Created by MINJEONG on 7/23/25.
//

import SwiftUI
///섹션버튼 Modifier
struct SectionButtomLable: ViewModifier {
    let isSelected: Bool

    func body(content: Content) ->  some View {
        content
            .font(.presemi24)
            .foregroundColor(isSelected ? .accent1 : .secondary2)
            .padding(.horizontal, 8)
            .frame(height: 45)
            .background(Color.secondary5)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .overlay(
                    RoundedRectangle(cornerRadius: 32)
                       .stroke(Color.white, lineWidth: 1)
                    )
            .shadow(color: Color.maintext.opacity(0.25), radius: 4)
      
    }
}
extension View {
    func sectionButtonLable(isSelected: Bool) -> some View {
        self.modifier(SectionButtomLable(isSelected: isSelected))
    }
}
