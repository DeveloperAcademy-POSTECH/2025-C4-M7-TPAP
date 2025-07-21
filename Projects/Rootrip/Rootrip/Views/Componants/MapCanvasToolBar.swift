import SwiftUI
import PencilKit

//TODO: 툴바도 두개로 분리해 주어야 함
struct MapCanvasToolBar: View {
    @Binding var showMapCanvas: Bool
    @Binding var isDrawing: Bool
    @Binding var showSidebar: Bool
    var onSelectTool: (PKTool) -> Void
    
    var body: some View {
        VStack(spacing: 0){
            ZStack {
                HStack{
                    Image(systemName: "sidebar.left")
                        .padding(.leading, 20)
                    Spacer()
                    Text("TPAP 우정여행")
                    Spacer()
                    Image(systemName: "arrow.uturn.backward")
                    Image(systemName: "arrow.uturn.forward")
                    
                    Text("잠금")
                    Text("저장")
                    Button(action: {
                        withAnimation(.linear){
                            showMapCanvas = false
                        }
                    }){
                        Text("홈")
                    }
                        .padding(.trailing, 20)
                }
                .foregroundStyle(.white)
            }
            .frame(height: 50) // 툴바 콘텐츠의 높이 지정
            .background(
                Color.point
                    .ignoresSafeArea(.container, edges: .top)
            )
            
            ZStack {
                HStack{
                    Spacer()
                    //커스텀 슬라이더 여기로 와야함
                    Slider(value: .constant(0.5), in: 0...1)
                        .frame(width: 100)
                    
                    Image(systemName: "eraser")
                        .onTapGesture {
                            isDrawing = true
                            onSelectTool(PKEraserTool(PKEraserTool.EraserType.vector))
                        }
                    Image(systemName: "pencil.circle.fill")
                        .onTapGesture {
                            isDrawing = true
                            
                            let penTool = PKInkingTool(.pen, color: .black, width: 5)
                            onSelectTool(penTool)
                        }
                    Image(systemName: "pencil.tip.crop.circle.fill")
                        .onTapGesture {
                            isDrawing = true
                            let penTool = PKInkingTool(.pen, color: .black, width: 5)
                            onSelectTool(penTool)
                        }
                    Image(systemName: "paintpalette")
                        .padding(.trailing, 50)
                }
            }
            .frame(height: 50) // 툴바 콘텐츠의 높이 지정
            .background(
                Color.white
            )
        }
    }
}

//#Preview {
//    MapCanvasToolBar()
//}
