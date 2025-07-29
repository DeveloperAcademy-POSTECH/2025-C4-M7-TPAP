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
                        Spacer()
                            .frame(height: 70)
                        
                        HStack {
                            codeInputButton
                                .opacity(isEditing ? 0 : 1)
                                .allowsHitTesting(!isEditing)
                                .frame(height: 0)
                            Spacer()
                        }
                        .padding(.horizontal, 80)
                        .padding(.top, 17)
                        .padding(.bottom, 30)
                        
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
                
                // TODO: 전면 리펙토링. scroll View에서 자연스러운 형태로 사용하려면 ZStack에 뷰를 넣는게 아니라 toolbar나 navigationbar을 사용해야함
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
                .font(.presemi16)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(.secondary4)
        .cornerRadius(36)
        .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
    }
}

#Preview(traits: .landscapeLeft) {
    BlockView()
        .environmentObject(PlanManager())
        .environmentObject(LocationManager())
}
