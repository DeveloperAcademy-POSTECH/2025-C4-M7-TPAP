import SwiftUI


struct PenThicknessSlider: View {
    @State var thickness: CGFloat = 1.0 //TODO: 굵기 관리하는 뷰에서 바인딩 필요

    let minThickness: CGFloat = 1
    let maxThickness: CGFloat = 20

    let trackWidth: CGFloat = 131
    let trackHeight: CGFloat = 16
    let handleSize: CGFloat = 26

    var body: some View {
        ZStack(alignment: .leading) {
            PencilBarShape()
                .fill(Color.gray) //TODO: 색상수정필요
                .frame(width: trackWidth, height: trackHeight)

            Circle()
                .stroke(Color.black, lineWidth: 2)
                .background(Circle().fill(Color.white))
                .frame(width: handleSize, height: handleSize)
                .offset(x: handleOffset(for: thickness))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let location = value.location.x
                            let clamped = min(max(0, location), trackWidth)
                            let percent = clamped / trackWidth
                            thickness = minThickness + percent * (maxThickness - minThickness)
                        }
                )
        }
        .frame(width: trackWidth, height: handleSize)
    }

    private func handleOffset(for thickness: CGFloat) -> CGFloat {
        let percent = (thickness - minThickness) / (maxThickness - minThickness)
        return percent * trackWidth - handleSize / 2
    }
}
    
    
struct PencilBarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let thinHeight: CGFloat = 2
        let fatHeight = rect.height
        let radius = fatHeight / 2
        let centerY = rect.midY

        path.move(to: CGPoint(x: 0, y: centerY - thinHeight / 2))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: centerY - fatHeight / 2))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: centerY),
                    radius: radius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(90),
                    clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: centerY + thinHeight / 2))
        path.closeSubpath()

        return path
    }
}

#Preview {
    PenThicknessSlider()
}
