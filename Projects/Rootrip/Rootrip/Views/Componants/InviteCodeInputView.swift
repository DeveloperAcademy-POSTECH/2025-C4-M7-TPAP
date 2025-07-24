//
//  InviteCodeInputView .swift
//  Rootrip
//
//  Created by Ella's Mac on 7/24/25.
//

import SwiftUI

struct InviteCodeInputView: View {
    @State var code: String = ""
    @Binding var isShowingCodeSheet: Bool
    
    var body: some View {
        ZStack {
            Color.maintext.opacity(0.4).ignoresSafeArea()
            
            Rectangle()
                .frame(width:562, height: 316)
                .foregroundStyle(.mainbackground)
                .cornerRadius(16)
                .overlay (
                    VStack {
                        headerView
                        
                        Spacer()
                        HStack {
                            Text("초대받은 참여코드를 입력하세요.")
                                .foregroundStyle(.secondary2)
                                .font(.prereg14)
                            Spacer()
                        }
                        .padding(.horizontal, 36)
                        
                        VStack(spacing: 28) {
                            TextField("", text: $code)
                                .textFieldStyle(RoundedTextFieldStyle())
                                .padding(.horizontal, 33)
                            
                            Button {
                                //TODO: 플랜 참가 능력 구현해야함
                                isShowingCodeSheet = false
                            } label: {
                                
                                Text("플랜 참가")
                                    .font(.presemi20)
                                    .foregroundStyle(code.isEmpty ? Color.secondary2 : Color.secondary4)
                                    .padding(.horizontal, 209)
                                    .padding(.vertical, 23)
                                    .background(code.isEmpty ? Color.secondary3 : Color.primary1)
                                    .cornerRadius(16)
                                
                            }
                        }
                        
                        Spacer()
                    }
                )
        }
    }
    
    //MARK: - heardrView
    private var headerView: some View {
        ZStack {
            Rectangle()
                .frame(width:562, height: 62)
                .foregroundStyle(.mainbackground)
                .clipShape(
                    RoundedCorner(radius: 16, corners: [.topLeft, .topRight])
                )
                .shadow(color: .secondary2.opacity(0.1), radius: 4, x: 0, y: 4)
                .overlay (
                    HStack {
                        Button {
                            isShowingCodeSheet = false
                        } label: {
                            Text("취소")
                                .font(.prereg16)
                                .foregroundStyle(.primary1)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text("코드로 참여하기")
                            .foregroundStyle(.secondary1)
                            .font(.presemi20)
                        
                        Spacer()
                    }
                        .padding(.horizontal)
                )
        }
    }
}


//MARK: - hearder rectangle
struct RoundedCorner: Shape {
    var radius: CGFloat = 16.0
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - 텍스트필드 스타일
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 20) // 여유만 주기
            .padding(.vertical, 23)
            .background(Color.secondary4)
            .cornerRadius(16)
            .font(.presemi20)
    }
}
