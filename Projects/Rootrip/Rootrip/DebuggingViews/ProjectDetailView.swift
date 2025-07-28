//
//  ProjectDetailView.swift
//  Rootrip
//
//  Created by Ella's Mac on 7/24/25.
//

import SwiftUI
import FirebaseFirestore

struct ProjectDetailView: View {
    let project: Project
    @State private var currentProject: Project?
    @State private var invitationCode: String = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Text("이건 프로젝트 상세 화면이야!")
            Text("projectTitle: \(currentProject?.title ?? project.title)")
            Text("projectID: \(currentProject?.id ?? project.id ?? "N/A")")
            
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
            observeProjectChanges()
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
                await MainActor.run {
                    self.invitationCode = code
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.invitationCode = "로드 실패"
                    self.isLoading = false
                }
            }
        }
    }
    
    /// Firestore 실시간 리스너
    private func observeProjectChanges() {
        guard let projectID = project.id else { return }
        Firestore.firestore()
            .collection("Rootrip")
            .document(projectID)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ 실시간 프로젝트 업데이트 실패: \(error.localizedDescription)")
                    return
                }
                guard let snapshot = snapshot else { return }
                do {
                    if let updatedProject = try snapshot.data(as: Project?.self) {
                        self.currentProject = updatedProject
                        print("🔄 실시간 업데이트: \(updatedProject.title)")
                    }
                } catch {
                    print("❌ 프로젝트 변환 실패: \(error.localizedDescription)")
                }
            }
    }
}
//#Preview {
//    ProjectDetailView(projectID: "hi")
//}
