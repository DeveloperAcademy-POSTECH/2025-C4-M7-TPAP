import SwiftUI

struct ProjectCard: View {
    let project: Project
    var isHighlighted: Bool = false // 최신순으로 정렬
    var isEditing: Bool = true
    var isSelected: Bool = true
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // TODO: 지도 이미지 들어가도록 만들어야함
            Rectangle()
                .foregroundStyle(.white)
                .frame(maxWidth: isHighlighted ? 1070 : 325, maxHeight: isHighlighted ? 380 : 190)
                .clipped()
                .overlay(
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.point.opacity(0.7), .clear]),
                            startPoint: .bottom,
                            endPoint: .center
                        )
                        
                        //카드에 들어가는 텍스트 (제목, 날짜 등)
                        VStack {
                            Spacer()
                            HStack {
                                // 여행 제목
                                Text(project.title)
                                    .font(.system(size: isHighlighted ? 32 : 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                // 날짜 표시
                                VStack(alignment: .trailing, spacing: 4) {
                                    if let end = project.endDate {
                                        VStack (spacing: 4) {
                                            Text(formattedDate(project.startDate))
                                            
                                            Rectangle()
                                                .fill(Color.white)
                                                .frame(width:isHighlighted ? 20: 14,
                                                       height: 1)
                                            
                                            Text(formattedDate(end))
                                        }
                                    } else {
                                        Text(formattedDate(project.startDate))
                                    }
                                }
                                .font(.system(size: isHighlighted ? 20 : 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(isHighlighted ? 24 : 16)
                        }
                    }
                )
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.4),
                        radius: isHighlighted ? 8 : 4, x: 0, y: 2)
            
            
            // 편집 모드일 때 체크 동그라미
            //TODO: asset정해지면 체크박스 색상 수정해야함
            if isEditing {
                let size: CGFloat = isHighlighted ? 39 : 33
                let checkmarkSize: CGFloat = isHighlighted ? 16 : 12
                let padding: CGFloat = isHighlighted ? 16 : 10
                
                ZStack {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .background(Circle().fill(isSelected ? Color.green : Color.gray))
                        .frame(width: size, height: size)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: checkmarkSize, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(padding)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

//MARK: - Preview
#Preview(traits: .landscapeLeft) {
    ProjectCard(
        project: Project(
            title: "TPAP 우정 여행",
            tripType: .overnightTrip,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
        ),
        isHighlighted: true
    )
}
