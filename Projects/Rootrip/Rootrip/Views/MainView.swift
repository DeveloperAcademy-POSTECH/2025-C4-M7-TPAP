import SwiftUI

struct MainView: View {
    @State var showMapCanvas = false
    
    var body: some View {
        if !showMapCanvas {
            VStack {
                MainViewToolBar()
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.point, Color.point.opacity(0.2)]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: UIScreen.main.bounds.height / 2.5)
                    .cornerRadius(20)
                    .padding(50)
                    .shadow(radius: 10)
                    .overlay(
                        Text("눌러서 MapCanvas로 이동")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                    .onTapGesture {
                        withAnimation(.linear) {
                            showMapCanvas = true
                        }
                    }
                Spacer()
            }
            
        } else {
            MapCanvas(showMapCanvas: $showMapCanvas)
        }
    }
}


#Preview {
    MainView()
}
