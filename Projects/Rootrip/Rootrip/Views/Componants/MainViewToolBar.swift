import SwiftUI

// MainViewToolBar: 상단 툴바
struct MainViewToolBar: View {
    
    @State private var isShowingPopover:Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                Text("Rootrip")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // 2. 버튼들 (오른쪽 정렬)
            HStack(spacing: 36) {
                Spacer() // 왼쪽에 공간을 만들어 버튼들을 오른쪽으로 밉니다.
                
                Button(action: {
                    // 일기 추가 액션
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }
                
                Button(action: {
                    // 일기 수정 액션
                }) {
                    Text("선택")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                }
                
                Button(action: {
                    isShowingPopover.toggle()
                }) {
                    //TODO: 프로필 사진 들어가도록 해야함
                    Circle()
                        .frame(width: 34, height: 34)
                        .foregroundStyle(.white)
                }
                .popover(isPresented: $isShowingPopover, arrowEdge: .top) {
                    ProfilePopover()
                }
            }
            .padding(.horizontal) // 좌우 여백
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
