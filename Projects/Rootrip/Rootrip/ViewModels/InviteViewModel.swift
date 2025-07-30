import Foundation
import FirebaseFirestore
import UIKit

@MainActor
final class InviteViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var joinedProject: Project?
    @Published var isLoading: Bool = false
    @Published var copiedCode: String? = nil
    
    private let projectRepository: ProjectRepositoryProtocol
    private let inviteRepository: ProjectInvitationProtocol
    
    init(
        projectRepository: ProjectRepositoryProtocol = ProjectRepository(),
        inviteRepository: ProjectInvitationProtocol = ProjectInvitationRepository()
    ) {
        self.projectRepository = projectRepository
        self.inviteRepository = inviteRepository
    }
    
    /// 초대 코드로 프로젝트 참여
    func joinProject(with code: String, userID: String) async {
        // 상태 초기화
        errorMessage = nil
        joinedProject = nil
        isLoading = true
        
        do {
            print("🔍 초대 코드로 프로젝트 참여 시도: \(code)")
            
            // 1. 초대 코드로 projectID 조회
            guard let invitation = try await inviteRepository.fetchInvitation(by: code) else {
                self.errorMessage = "유효하지 않은 초대 코드입니다."
                self.isLoading = false
                return
            }
            
            print("📋 초대 코드 유효, 프로젝트 ID: \(invitation.projectID)")
            
            // 2. Firestore에서 프로젝트 정보 먼저 가져오기
            let projectSnapshot = try await Firestore.firestore()
                .collection("Rootrip")
                .document(invitation.projectID)
                .getDocument()
            
            guard projectSnapshot.exists else {
                self.errorMessage = "프로젝트를 찾을 수 없습니다."
                self.isLoading = false
                return
            }
            
            var project = try projectSnapshot.data(as: Project.self)
            
            // 3. 이미 멤버인지 확인
            if project.memberIDs.contains(userID) {
                self.errorMessage = "이미 참여 중인 프로젝트입니다."
                self.joinedProject = project // 이미 참여 중이어도 프로젝트 정보는 설정
                self.isLoading = false
                return
            }
            
            // 4. 해당 프로젝트에 사용자 추가
            try await projectRepository.addMember(to: invitation.projectID, userID: userID)
            
            // 5. 로컬 프로젝트 객체의 memberIDs 업데이트
            var updatedProject = project
            updatedProject.memberIDs.append(userID)
            
            self.joinedProject = updatedProject
            print("✅ \(userID) → \(invitation.projectID) 프로젝트에 참여 완료")
            
        } catch {
            print("❌ 프로젝트 참여 실패: \(error.localizedDescription)")
            self.errorMessage = "프로젝트 참여에 실패했습니다: \(error.localizedDescription)"
        }
        
        self.isLoading = false
    }
    
    /// 상태 초기화
    func resetState() {
        errorMessage = nil
        joinedProject = nil
        isLoading = false
    }
    
    func copyInviteCode(for projectID: String) async {
        do {
            let invitation = try await inviteRepository.createInvitation(for: projectID)
            let code = invitation.id
            UIPasteboard.general.string = code
            
            // 토스트 표시용으로 코드 설정
            copiedCode = code

            // 2초 후에 메시지 자동 삭제 (토스트 사라지게)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.copiedCode = nil
            }
            
        } catch {
            print("❌ 초대 코드 복사 실패: \(error.localizedDescription)")
            self.errorMessage = "초대 코드 복사 실패"
        }
    }
}
