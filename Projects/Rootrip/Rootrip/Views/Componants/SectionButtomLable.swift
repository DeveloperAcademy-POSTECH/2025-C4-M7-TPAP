//
//  SectionButtomLable.swift
//  Rootrip
//
//  Created by MINJEONG on 7/23/25.
//

import SwiftUI

struct SectionButtomLable: ViewModifier {
    let isSelected: Bool

    func body(content: Content) ->  some View {
        content
            .font(.presemi24)
            .foregroundColor(isSelected ? .accent1 : .secondary2)
            .padding(.horizontal, 8)
            .frame(height: 45)
            .background(Color.secondary4)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(radius: 4)
    }
}
extension View {
    func sectionButtonLable(isSelected: Bool) -> some View {
        self.modifier(SectionButtomLable(isSelected: isSelected))
    }
}
