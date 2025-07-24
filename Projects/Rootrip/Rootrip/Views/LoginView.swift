import SwiftUI

struct LoginView: View {
    @State var isLoggedIn: Bool = false
    
    var body: some View {
        if !isLoggedIn{
            ZStack{
                Color.primary1
                Image("Login")
                
                VStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut){
                            isLoggedIn.toggle()
                        }
                    }) {
                        Image("appleid_button")
                    }
                    .padding(.bottom, 216)
                }
            }
            .ignoresSafeArea(.all)
        }
        else{
            //TODO: - 메인뷰 이름 변경(엘라)
            MainView()
                .environmentObject(PlanManager())
                .environmentObject(RouteManager())
        }
    }
}



#Preview(traits: .landscapeLeft){
    LoginView()
}
