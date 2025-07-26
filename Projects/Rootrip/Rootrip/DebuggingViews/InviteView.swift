//
//  InviteView.swift
//  Rootrip
//
//  Created by Ella's Mac on 7/22/25.
//

//import SwiftUI
//
//struct InviteView: View {
//    @StateObject private var viewModel = InviteViewModel()
//      @State private var projectID: String = ""      // 테스트용 프로젝트 ID
//      @State private var invitationCode: String = "" // 입력받은 초대 코드
//      @State private var userID: String = ""         // 현재 사용자 ID
//
//      var body: some View {
//          VStack(spacing: 20) {
//              TextField("프로젝트 ID 입력", text: $projectID)
//                  .textFieldStyle(.roundedBorder)
//
//              Button("초대 코드 생성") {
//                  Task {
//                      await viewModel.createInvitation(for: projectID)
//                  }
//              }
//
//              Divider().padding(.vertical)
//
//              TextField("초대 코드 입력", text: $invitationCode)
//                  .textFieldStyle(.roundedBorder)
//
//              TextField("유저 ID 입력", text: $userID)
//                  .textFieldStyle(.roundedBorder)
//
//              Button("초대 코드로 참여하기") {
//                  Task {
//                      await viewModel.joinProject(with: invitationCode, currentUserID: userID)
//                  }
//              }
//          }
//          .padding()
//      }
//  }
//
//#Preview {
//    InviteView()
//}
