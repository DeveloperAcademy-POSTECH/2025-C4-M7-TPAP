import SwiftUI

struct ProjectCard: View {
    let project: Project
    var isHighlighted: Bool = false // 최신순으로 정렬
    var isEditing: Bool = true
    var isSelected: Bool = true
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            normalCardView
            if isEditing {
                editCardView
            }
        }
    }
    
    private var normalCardView: some View {
        baseCard(
            width: isHighlighted ? 1070 : 325,
            height: isHighlighted ? 380 : 190
        ) {
            if isHighlighted {
                hilightContent
            } else {
                cardContent
            }
        }
    }

    // MARK: - Background Layer
    @ViewBuilder
    private func baseCard(width: CGFloat, height: CGFloat, @ViewBuilder content: () -> some View ) -> some View {
        Rectangle() // TODO: 지도 이미지 들어가도록 만들어야 함
            .foregroundStyle(.primary1)
            .frame(maxWidth: width, maxHeight: height)
            .clipped()
            .overlay(content())
            .cornerRadius(16)
    }

    // MARK: - Overlay Content
    @ViewBuilder
    private var hilightContent: some View {
        ZStack {
            if isEditing {
                Color.black.opacity(0.2)
            }
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4941, green: 0.5569, blue: 0.902).opacity(0.7),
                    .clear
                ]),
                startPoint: .bottom,
                endPoint: .center
            )
            VStack {
                Spacer()
                HStack {
                    titleText
                    Spacer()
                    dateView
                }
                .padding(24)
            }
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        ZStack {
            if isEditing {
                Color.black.opacity(0.2)
            }
            VStack {
                Spacer()
                HStack {
                    titleText
                    Spacer()
                    dateView
                }
                .padding(16)
            }
        }
    }

    
    private var titleText: some View {
        Text(project.title)
            .font(.system(size: isHighlighted ? 32 : 18, weight: .bold))
            .foregroundColor(.secondary4)
            .multilineTextAlignment(.leading)
    }
    
    private var dateView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if let end = project.endDate {
                VStack(spacing: 4) {
                    Text(formattedDate(project.startDate))
                    Rectangle()
                        .fill(Color.secondary4)
                        .frame(width: isHighlighted ? 20 : 14, height: 1)
                    Text(formattedDate(end))
                }
            } else {
                Text(formattedDate(project.startDate))
            }
        }
        .font(.system(size: isHighlighted ? 20 : 12, weight: .bold))
        .foregroundColor(.secondary4.opacity(0.9))
    }
    
    // MARK: - Checkmark Layer
    private var editCardView: some View {
        let size: CGFloat = isHighlighted ? 39 : 33
        let checkmarkSize: CGFloat = isHighlighted ? 16 : 12
        let padding: CGFloat = isHighlighted ? 16 : 10
        
        return ZStack {
            Circle()
                .strokeBorder(Color.secondary4, lineWidth: 3)
                .background(Circle().fill(isSelected ? Color.accent1 : Color.secondary3))
                .frame(width: size, height: size)
            
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: checkmarkSize, weight: .bold))
                    .foregroundColor(.secondary4)
            }
        }
        .padding(padding)
    }
    
    // MARK: - Date Formatter
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
