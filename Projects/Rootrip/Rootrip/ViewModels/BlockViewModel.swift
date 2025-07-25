import Foundation

@MainActor
final class BlockViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var newProjectForNavigation: Project? = nil
    @Published var newInvitationCode: String? = nil

    private let repository: ProjectRepositoryProtocol
    private let inviteRepository: ProjectInvitationProtocol

    init(
         repository: ProjectRepositoryProtocol = ProjectRepository(),
         inviteRepository: ProjectInvitationProtocol = ProjectInvitationRepository()
     ) {
         self.repository = repository
         self.inviteRepository = inviteRepository
     }

    func fetchProjects() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await repository.fetchAllProjects()
            
            self.projects = result
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    /// 새로운 프로젝트를 생성하고 내비게이션을 준비하는 함수
    func createNewProject() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newProject = try await repository.createProject(
                title: nil,         // 제목 자동 생성
                tripType: .dayTrip, // 기본 당일치기
                startDate: Date(),
                endDate: nil
            )
            
            self.newProjectForNavigation = newProject
            print("✅ 새 프로젝트 생성 완료: \(newProject.title) (ID: \(newProject.id ?? "N/A"))")
                        
            // 프로젝트 목록 갱신
            await fetchProjects()
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ 프로젝트 생성 실패: \(error.localizedDescription)")
        }
        
        self.isLoading = false
    }
    
    // 프로젝트 생성 후 목록 새로고침을 위한 함수
    func refreshProjects() {
        Task {
            await fetchProjects()
        }
    }
    
    func deleteProjects(projectIDs: [String]) async {
        for id in projectIDs {
            do {
                try await repository.deleteProject(projectID: id)
                print("🗑️ 삭제 완료: \(id)")
            } catch {
                print("❌ 삭제 실패: \(id) - \(error)")
            }
        }
        await fetchProjects()
    }
}
