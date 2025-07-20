import SwiftUI

// MainViewToolBar: 상단 툴바
struct MainViewToolBar: View {
    
    @State private var isShowingPopover:Bool = false
    @Binding var isEditing: Bool
    @Binding var selectedProjects: Set<String>
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = UIScreen.main.bounds.width
            let trailingPadding: CGFloat = screenWidth >= 1300 ? 20 : 60
            ZStack {
                HStack {
                    Text("Rootrip")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
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
                Color.point
                    .ignoresSafeArea(.container, edges: .top)
            )
        }
    }
    // MARK: - 선택 모드 버튼
    private var editingButtons: some View {
        Group {
            Button {
                isEditing = false
            } label: {
                Text("삭제")
                    .font(.system(size: 20))
                    .foregroundStyle(.red)
                    .bold()
            }
            .disabled(selectedProjects.isEmpty)
            .opacity(selectedProjects.isEmpty ? 0.5 : 1.0)
            
            Button {
                isEditing = false
                selectedProjects.removeAll()
            } label: {
                Text("완료")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .bold()
            }
        }
    }
    
    // MARK: - 기본 모드 버튼
    private var normalButtons: some View {
        Group {
            NavigationLink {
                // TODO: Plan 생성 화면으로 이동
                EmptyView()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }
            
            Button {
                isEditing = true
                selectedProjects.removeAll() //선택을 전부 해제
            } label: {
                Text("선택")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }
            
            Button {
                isShowingPopover.toggle()
            } label: {
                Circle()
                    .frame(width: 34, height: 34)
                    .foregroundStyle(.white)
            }
            .popover(isPresented: $isShowingPopover, arrowEdge: .top) {
                ProfilePopover()
            }
        }
    }
}



// MARK: - 프로필 팝오버 뷰
struct ProfilePopover: View {
    var body: some View {
        VStack {
            Button {
                // TODO: 로그아웃 기능 추가
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
                // TODO: 탈퇴 기능 추가
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
