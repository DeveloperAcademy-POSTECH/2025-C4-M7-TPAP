import SwiftUI

struct ContentView: View {
    @State var isLoggedIn: Bool = false
    @State private var projects: [Project] = []
    @State private var selectedProjects: Set<String> = []
    @State private var isEditing: Bool = false
    
    var body: some View {
        if !isLoggedIn{
            ZStack{
                Color.point
                
                
                VStack {
                    Text("RooTrip")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Button("🍎 로그인 버튼"){
                        withAnimation(.linear){
                            isLoggedIn.toggle()
                        }
                    }
                    .buttonStyle(BorderedButtonStyle()) // 이 부분은 선택 사항입니다.
                }
                .padding(150)
                .background(.white)
                .cornerRadius(20)
                
            }
            .ignoresSafeArea(.all)
        } else {
            MainView()
        }
        /*ProjectListView(
            projects: $projects,
            selectedProjects: $selectedProjects,
            isEditing: $isEditing
        )*/
        
    }
}



#Preview {
    ContentView()
}
