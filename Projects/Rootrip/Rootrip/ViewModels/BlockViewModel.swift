
import Foundation

@MainActor
final class BlockViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var newProjectForNavigation: Project? = nil // 내비게이션을 위해 새로 생성된 프로젝트를 저장할 속성

    private let repository: ProjectRepositoryProtocol

    init(repository: ProjectRepositoryProtocol = ProjectRepository()) {
        self.repository = repository
    }

    func fetchProjects() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await repository.fetchAllProjects()
            
            // @MainActor 클래스이므로 MainActor.run은 필수는 아니지만 명시적으로 사용해도 좋습니다.
            self.projects = result
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    // 새로운 프로젝트를 생성하고 내비게이션을 준비하는 함수
    func createNewProject() async {
        isLoading = true
        errorMessage = nil
        do {
            let newProject = try await repository.createProject(
                title: nil, // 제목 자동 생성
                tripType: .dayTrip, // 기본 여행 타입: 당일치기
                startDate: Date(),
                endDate: nil
            )
            self.newProjectForNavigation = newProject // 내비게이션을 트리거하기 위해 프로젝트 설정
            print("✅ BlockViewModel: newProjectForNavigation 설정됨: \(newProject.title) (ID: \(newProject.id ?? "N/A"))")
            await fetchProjects()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        self.isLoading = false
    }
    
    // 프로젝트 생성 후 목록 새로고침을 위한 기존 함수
    func refreshProjects() {
        Task {
            await fetchProjects()
        }
    }
}
