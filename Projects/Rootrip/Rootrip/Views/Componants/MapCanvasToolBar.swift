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
                    
                    Button(action:{
                        
                    }){
                        Image(systemName: "arrow.uturn.backward")
                    }
                    
                    Button(action:{
                        
                    }){
                        Image(systemName: "arrow.uturn.forward")
                    }
                    
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
                .foregroundStyle(.secondary4)
            }
            .frame(height: 50) // 툴바 콘텐츠의 높이 지정
            .background(
                Color.primary1
                    .ignoresSafeArea(.container, edges: .top)
            )
            
            ZStack {
                HStack{
                    Spacer()
                    //커스텀 슬라이더 여기로 와야함
                    Slider(value: .constant(0.5), in: 0...1)
                        .frame(width: 100)
                    
                    Image(systemName: "eraser")
                    Image(systemName: "pencil.circle.fill")
                    Image(systemName: "pencil.tip.crop.circle.fill")
                    Image(systemName: "paintpalette")
                        .padding(.trailing, 50)
                }
            }
            .frame(height: 50) // 툴바 콘텐츠의 높이 지정
            .background(
                Color.secondary4
            )
        }
    }
}

#Preview {
    MapCanvasToolBar(isSidebarOpen: .constant(true))
        .environmentObject(PlanManager())
        .environmentObject(RouteManager())
}
