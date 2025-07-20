// ProjectListView, LargeCardView, SmallCardRowView 세 컴포넌트로 구성
// selectedProjects는 Set<String>으로, 정렬은 createdDate 기준
//TODO: 카드뷰 눌렀을때 DetailView로 넘어가도록 해야함
import SwiftUI

// MARK: - ProjectListView
struct ProjectListView: View {
    let projects: [Project]
    @Binding var selectedProjects: Set<String> // Firebase용 id는 String
    @Binding var isEditing: Bool
    
    var sortedProjects: [Project] {
        projects.sorted { $0.createdDate > $1.createdDate }
    }
    
    var body: some View {
        VStack(spacing: 32) {
            
            // 가장 최신 프로젝트
            if let first = sortedProjects.first {
                HStack {
                    Spacer()
                    LargeCardView(
                        project: first,
                        isEditing: isEditing,
                        isSelected: selectedProjects.contains(first.id ?? ""),
                        toggleSelection: {
                            toggleSelection(for: first.id)
                        }
                    )
                    .frame(width: 1070, height: 380)
                    Spacer()
                }
                .padding(.horizontal, 100)
            }
            
            // 나머지 프로젝트 (작은 카드 3개씩)
            let smallProjects = Array(sortedProjects.dropFirst())
            
            ForEach(Array(stride(from: 0, to: smallProjects.count, by: 3)), id: \.self) { index in
                SmallCardRowView(
                    projects: smallProjects,
                    startIndex: index,
                    isEditing: isEditing,
                    selectedProjects: $selectedProjects
                )
            }
        }
    }
    
    private func toggleSelection(for id: String?) {
        guard let id else { return }
        if selectedProjects.contains(id) {
            selectedProjects.remove(id)
        } else {
            selectedProjects.insert(id)
        }
    }
}

// MARK: - LargeCardView
struct LargeCardView: View {
    let project: Project
    var isEditing: Bool
    var isSelected: Bool
    var toggleSelection: () -> Void

    var body: some View {
        if isEditing {
            Button(action: toggleSelection) {
                ProjectCard(
                    project: project,
                    isHighlighted: true,
                    isEditing: true,
                    isSelected: isSelected
                )
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(destination: EmptyView()) {
                ProjectCard(
                    project: project,
                    isHighlighted: true,
                    isEditing: false,
                    isSelected: false
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - SmallCardRowView
struct SmallCardRowView: View {
    let projects: [Project]
    let startIndex: Int
    let isEditing: Bool
    @Binding var selectedProjects: Set<String>
    
    var body: some View {
        HStack(spacing: 44) {
            ForEach(0..<3) { offset in
                if startIndex + offset < projects.count {
                    let project = projects[startIndex + offset]
                    if isEditing {
                        Button {
                            toggleSelection(for: project.id)
                        } label: {
                            ProjectCard(
                                project: project,
                                isHighlighted: false,
                                isEditing: true,
                                isSelected: selectedProjects.contains(project.id ?? "")
                            )
                            .frame(width: 325, height: 190)
                        }
                        .buttonStyle(.plain)
                    } else {
                        NavigationLink(destination: EmptyView()) {
                            ProjectCard(
                                project: project,
                                isHighlighted: false,
                                isEditing: false,
                                isSelected: false
                            )
                            .frame(width: 325, height: 190)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Spacer().frame(width: 325)
                }
            }
        }
    }
    
    //Firebase에서 불러온 데이터를 UI에서 사용하기 위한 함수
    private func toggleSelection(for id: String?) {
        guard let id else { return }
        if selectedProjects.contains(id) {
            selectedProjects.remove(id)
        } else {
            selectedProjects.insert(id)
        }
    }
}
