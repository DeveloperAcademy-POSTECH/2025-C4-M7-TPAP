//
//  DeleteAccountAlert.swift
//  Rootrip
//
//  Created by Ella's Mac on 7/23/25.
//

import SwiftUI

struct DeleteAccountAlert: View {
    //TODO: 글자 폰트 수정 필요
    
    var onCancel: () -> Void
    var onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.maintext.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 0) {
                Text("탈퇴 하시겠습니까?")
                    .font(.presemi16)
                    .padding(.vertical, 20)
                    .foregroundStyle(.maintext)

                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color.gray.opacity(0.3))

                HStack(spacing: 0) {
                    Spacer()

                    Button(action: onCancel) {
                        Text("취소")
                            .font(.presemi16)
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 100, height: 20)

                    Spacer()

                    Rectangle()
                        .frame(width: 1)
                        .foregroundStyle(Color.gray.opacity(0.3))

                    Spacer()

                    Button(action: onConfirm) {
                        Text("확인")
                            .font(.prereg16)
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 100, height: 20)

                    Spacer()
                }
            }
            .frame(width: 270, height: 105)
            .background(.secondary4)
            .cornerRadius(14)
        }
    }
}
