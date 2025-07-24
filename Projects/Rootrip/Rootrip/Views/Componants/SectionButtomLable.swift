//
//  SectionButtomLable.swift
//  Rootrip
//
//  Created by MINJEONG on 7/23/25.
//

import SwiftUI

struct SectionButtomLable: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.presemi24)
            .foregroundColor(isSelected ? .accent1 : .secondary2)
            .padding(.horizontal, 8)
            .frame(height: 45)
            .background(Color.secondary4)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(radius: 4)
    }
}

#Preview {
    SectionButtomLable(title: "Plan A", isSelected: false)
}
