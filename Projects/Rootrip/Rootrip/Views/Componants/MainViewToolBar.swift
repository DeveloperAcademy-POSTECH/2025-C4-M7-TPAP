import SwiftUI

// MainViewToolBar: 상단 툴바
struct MainViewToolBar: View {
    var body: some View {
        ZStack {
            HStack {
                Text("Rootrip")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // 2. 버튼들 (오른쪽 정렬)
            HStack(spacing: 20) {
                Spacer() // 왼쪽에 공간을 만들어 버튼들을 오른쪽으로 밉니다.
                
                Button(action: {
                    // 일기 추가 액션
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    // 일기 수정 액션
                }) {
                    Text("선택")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    // 프로필 이동 액션
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
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
