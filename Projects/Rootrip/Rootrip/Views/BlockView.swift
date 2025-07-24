import SwiftUI

struct BlockView: View {
    @StateObject private var viewModel = BlockViewModel()
    @State private var isEditing: Bool = false
    @State private var selectedProjects: Set<String> = []
    @State private var isShowingCodeSheet: Bool = false
    
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
                    selectedProjects: $selectedProjects
                )
                
                if isShowingCodeSheet {
                    InviteCodeInputView(isShowingCodeSheet: $isShowingCodeSheet)
                        .zIndex(1000)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden)
            .onAppear {
                Task {
                    await viewModel.fetchProjects()
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
