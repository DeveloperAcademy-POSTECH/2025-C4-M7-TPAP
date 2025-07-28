import SwiftUI

struct LoginView: View {
    @State var isLoggedIn: Bool = false
    
    var body: some View {
        if !isLoggedIn{
            ZStack{
                Color.primary1
                Image("loginbackground")
                VStack {
                    Spacer()
                    
                        Image("R")
                            
                        Text("ROOTRIP")
                            .font(.suereg24)
                            .foregroundColor(.primary1)
                            .padding(.bottom, 310)
                    
                }
                VStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut){
                            isLoggedIn.toggle()
                        }
                    }) {
                        Image("applebutton")
                    }
                    .padding(.bottom, 216)
                }
            }
            .ignoresSafeArea(.all)
        }
        else{
            BlockView()
                .environmentObject(PlanManager())
                .environmentObject(LocationManager())
                .environmentObject(BookmarkManager())
        }
    }
}



#Preview(traits: .landscapeLeft){
    LoginView()
}
