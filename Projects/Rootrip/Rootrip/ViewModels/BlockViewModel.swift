//
//  BlockViewModel.swift
//  Rootrip
//
//  Created by Ella's Mac on 7/24/25.
//

import Foundation

@MainActor
final class BlockViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let repository: ProjectRepositoryProtocol

    init(repository: ProjectRepositoryProtocol = ProjectRepository()) {
        self.repository = repository
    }

    func fetchProjects() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔍 프로젝트 불러오기 시작...")
            let result = try await repository.fetchAllProjects()
            print("🔍 불러온 프로젝트 개수: \(result.count)")
            
            // 메인 스레드에서 UI 업데이트 보장
            await MainActor.run {
                self.projects = result
                self.isLoading = false
            }
            
            // 각 프로젝트 정보 출력 (디버깅용)
            for project in result {
                print("📄 프로젝트: \(project.title), ID: \(project.id ?? "nil")")
            }
            
        } catch {
            print("🔥 프로젝트 불러오기 실패: \(error)")
            print("🔥 에러 상세: \(error.localizedDescription)")
            
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // 프로젝트 생성 후 목록 새로고침을 위한 함수
    func refreshProjects() {
        Task {
            await fetchProjects()
        }
    }
}
