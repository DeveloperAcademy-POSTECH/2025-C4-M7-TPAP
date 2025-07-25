import SwiftUI

//TODO: 툴바도 두개로 분리해 주어야 함
struct MapCanvasToolBar: View {
//    @Binding var showMapCanvas: Bool
    @State var isCanvasLocked: Bool = false
    @Binding var isSidebarOpen: Bool
    
    var body: some View {
        VStack(spacing: 0){
            ZStack (alignment: .topLeading){
                HStack(spacing: 20){
                    Button(action:{
                        withAnimation(){
                            isSidebarOpen.toggle()
                        }
                    }){
                        Image(systemName: "sidebar.left")
                            .padding(.leading, 20)
                    }
                    Spacer()
                    Button(action: {
                        
                    }){
                        Text("TPAP 우정여행")
                        Image(systemName: "chevron.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10)
                    }
                    Spacer()
                    Image(systemName: "arrow.uturn.backward")
                    Image(systemName: "arrow.uturn.forward")
                    
                    Button(action:{
                        withAnimation(.linear){
                            isCanvasLocked.toggle()
                        }
                    }){
                        Image(systemName: isCanvasLocked ? "lock.fill" : "lock.open.fill")
                        .frame(width: 20)
                    }
                    
                    Button(action:{
                        //저장 로직 여기에 입력
                    }){
                        Text("저장")
                    }
                    
                    Button(action: {
//                        withAnimation(.linear){
//                            showMapCanvas = false
//                        }
                    }){
                        Text("홈")
                    }
                        .padding(.trailing, 30)
                }
                .foregroundStyle(.white)
                
            }
            .frame(height: 50) // 툴바 콘텐츠의 높이 지정
            .background(
                Color.point
                    .ignoresSafeArea(.container, edges: .top)
            )
            
            
        }
    }
}

//#Preview {
//    MapCanvasToolBar()
//        .environmentObject(PlanManager())
//        .environmentObject(RouteManager())
//}
