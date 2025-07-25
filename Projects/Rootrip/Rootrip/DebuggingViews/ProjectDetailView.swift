//
//  ProjectDetailView.swift
//  Rootrip
//
//  Created by Ella's Mac on 7/24/25.
//

import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    @State private var invitationCode: String = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("이건 프로젝트 상세 화면이야!")
            Text("projectTitle: \(project.title)")
            Text("projectID: \(project.id ?? "N/A")")
            
            // 초대코드 표시
            VStack {
                Text("초대코드:")
                if isLoading {
                    ProgressView()
                } else {
                    Text(invitationCode.isEmpty ? "코드 없음" : invitationCode)
                        .textSelection(.enabled)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .onAppear {
            loadInvitationCode()
        }
    }
    
    private func loadInvitationCode() {
        guard let projectID = project.id else {
            print("❌ Project ID가 없어서 초대코드를 로드할 수 없습니다.")
            return
        }
        
        isLoading = true
        Task {
            do {
                let inviteRepository = ProjectInvitationRepository()
                let invitation = try await inviteRepository.createInvitation(for: projectID)
                let code = invitation.id ?? ""
                
                // 🎯 콘솔에 초대코드 출력
                print("🎫 초대코드: \(code)")
                print("📋 프로젝트: \(project.title) (ID: \(projectID))")
                
                await MainActor.run {
                    self.invitationCode = code
                    self.isLoading = false
                }
            } catch {
                print("❌ 초대코드 로드 실패: \(error.localizedDescription)")
                await MainActor.run {
                    self.invitationCode = "로드 실패"
                    self.isLoading = false
                }
            }
        }
    }
}
//#Preview {
//    ProjectDetailView(projectID: "hi")
//}
