import SwiftUI

struct BlockView: View {
    @StateObject private var viewModel = BlockViewModel()
    @State private var isEditing: Bool = false
    @State private var selectedProjects: Set<String> = []
    @State private var isShowingCodeSheet: Bool = false
    
    @State private var navigateToProjectDetail = false
    @State private var projectToNavigate: Project? = nil
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.mainbackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        Text("📦 projects.count = \(viewModel.projects.count)")
                            .foregroundStyle(.red)
                        Spacer()
                            .frame(height: 70)
                        
                        HStack {
                            codeInputButton
                                .opacity(isEditing ? 0 : 1)
                                .allowsHitTesting(!isEditing)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 80)
                        .padding(.bottom, 10)
                        
                        // 실제 프로젝트 리스트
                        ProjectListView(
                            projects: viewModel.projects,
                            selectedProjects: $selectedProjects,
                            isEditing: $isEditing
                        )
                    }
                    .refreshable {
                        await viewModel.fetchProjects()
                    }
                }
                
                MainViewToolBar(
                    isEditing: $isEditing,
                    selectedProjects: $selectedProjects,
                    onProjectCreated: { project in
                        self.projectToNavigate = project
                        self.navigateToProjectDetail = true
                    }
                )
                .environmentObject(viewModel)
                
                if isShowingCodeSheet {
                    InviteCodeInputView(isShowingCodeSheet: $isShowingCodeSheet)
                        .environmentObject(viewModel)
                        .zIndex(1000)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden)
            .onAppear {
                Task { await viewModel.fetchProjects() }
            }
            /// 새 프로젝트 생성
            // TODO: @Steve 네비게이션 플로우 정리해주세요
            .onChange(of: viewModel.newProjectForNavigation) { _, newValue in
                guard let project = newValue else { return }
                self.projectToNavigate = project
                self.navigateToProjectDetail = true
            }
            .navigationDestination(isPresented: $navigateToProjectDetail) {
                if let project = projectToNavigate {
                    ProjectView(project: project)
                        .onDisappear {
                            // detail에서 뒤로가기 시 초기화
                            viewModel.newProjectForNavigation = nil
                            projectToNavigate = nil
                            navigateToProjectDetail = false
                        }
                }
            }
        }
    }
    
    //MARK: - 코드참여버튼
    private var codeInputButton: some View {
        Button {
            isShowingCodeSheet = true
        } label: {
            Text("코드로 참여하기")
                .foregroundStyle(.primary1)
                .bold()
        }
        .buttonStyle(.plain)
        .padding(.vertical, 15)
        .padding(.horizontal, 26)
        .background(.secondary4)
        .cornerRadius(36)
        .shadow(color: .gray.opacity(0.4),
                radius: 6, x: 0, y: 0)
    }
}

#Preview(traits: .landscapeLeft) {
    BlockView()
        .environmentObject(PlanManager())
        .environmentObject(RouteManager())
}
