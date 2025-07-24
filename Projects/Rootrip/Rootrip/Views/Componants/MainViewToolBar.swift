import SwiftUI

// MainViewToolBar: 상단 툴바
struct MainViewToolBar: View {
    @EnvironmentObject var viewModel: BlockViewModel
    
    @State private var isShowingPopover:Bool = false
    @State private var isShowingLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    @Binding var isEditing: Bool
    @Binding var selectedProjects: Set<String>
    
    let onProjectCreated: (Project) -> Void
    
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = UIScreen.main.bounds.width
            let trailingPadding: CGFloat = screenWidth >= 1300 ? 20 : 70
            ZStack {
                HStack {
                    Text("Rootrip")
                        .fontWeight(.bold)
                        .foregroundColor(.secondary4)
                }
                
                // 2. 버튼들 (오른쪽 정렬)
                HStack(spacing: 36) {
                    Spacer()
                    
                    if isEditing {
                        editingButtons
                    } else {
                        normalButtons
                    }
                }
                .padding(.trailing, trailingPadding)
            }
            .frame(height: 50) // 툴바 콘텐츠의 높이 지정
            .background(
                // 3. 배경색을 ZStack의 background 수정자로 이동시킵니다.
                //    이렇게 하면 배경에만 ignoresSafeArea가 적용됩니다.
                Color.primary1
                    .ignoresSafeArea(.container, edges: .top)
            )
        }
        .overlay {
            if isShowingLogoutAlert {
                LogoutAlert(
                    onCancel: {
                        isShowingLogoutAlert = false
                    },
                    onConfirm: {
                        isShowingLogoutAlert = false
                        //TODO: 로그아웃 기능 추가
                    }
                )
            } else if showDeleteAccountAlert {
                DeleteAccountAlert (
                    onCancel: {
                        showDeleteAccountAlert = false
                    },
                    onConfirm: {
                        showDeleteAccountAlert = false
                        //TODO: 탈퇴 기능 추가
                    }
                )
            }
        }
    }
    
    
    // MARK: - 선택 모드 버튼
    private var editingButtons: some View {
        Group {
            Button {
                Task {
                    await viewModel.deleteProjects(projectIDs: Array(selectedProjects))
                    selectedProjects.removeAll()
                    isEditing = false
                }
                isEditing = false
            } label: {
                Image(systemName: "trash")
                    .font(.presemi20)
                    .foregroundStyle(.secondary4)
            }
            .disabled(selectedProjects.isEmpty)
            .opacity(selectedProjects.isEmpty ? 0.5 : 1.0)
            
            Button {
                isEditing = false
                selectedProjects.removeAll()
            } label: {
                Text("완료")
                    .font(.presemi20)
                    .foregroundStyle(.secondary4)
            }
        }
    }
    
    // MARK: - 기본 모드 버튼
    private var normalButtons: some View {
        Group {
            Button {
                Task {
                    await viewModel.createNewProject()
                    if let project = viewModel.newProjectForNavigation {
                        onProjectCreated(project)  // ✅ 트리거
                        viewModel.newProjectForNavigation = nil
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .font(.presemi20)
                    .foregroundStyle(.secondary4)
            }
            .buttonStyle(.plain)
            
            Button {
                isEditing = true
                selectedProjects.removeAll() //선택을 전부 해제
            } label: {
                Text("선택")
                    .font(.presemi20)
                    .foregroundStyle(.secondary4)
            }
            .buttonStyle(.plain)
            
            Button {
                isShowingPopover.toggle()
            } label: {
                Circle()
                    .frame(width: 34, height: 34)
                    .foregroundStyle(.secondary4)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isShowingPopover, arrowEdge: .top) {
                ProfilePopover(
                    isShowingLogoutAlert: $isShowingLogoutAlert,
                    isShowingPopover: $isShowingPopover,
                    showDeleteAccountAlert: $showDeleteAccountAlert
                )
            }
        }
    }
}



// MARK: - 프로필 팝오버 뷰
struct ProfilePopover: View {
    @Binding var isShowingLogoutAlert: Bool
    @Binding var isShowingPopover: Bool
    @Binding var showDeleteAccountAlert: Bool
    var body: some View {
        VStack {
            Button {
                isShowingPopover = false
                isShowingLogoutAlert = true
            } label: {
                Text("로그아웃")
                    .foregroundStyle(.red)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
            }
            .buttonStyle(.plain)
            
            Divider()
                .padding(.horizontal, 12)
            
            Button {
                isShowingPopover = false
                showDeleteAccountAlert = true
            } label: {
                Text("탈퇴하기")
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
            }
            .buttonStyle(.plain)
        }
    }
}
