import SwiftUI

struct BlockView: View {
    @State private var isEditing: Bool = false
    @State private var selectedProjects: Set<String> = []
    @State private var isShowingCodeSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.mainbackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        Spacer()
                            .frame(height: 70)
                        
                        HStack {
                            codeInputButton
                                .opacity(isEditing ? 0 : 1)
                                .allowsHitTesting(!isEditing) // 편집 모드일 땐 터치 안 되게 막기
                            
                            Spacer()
                        }
                        .padding(.horizontal, 60)
                        
                        
                        ProjectListView(
                            projects: sampleProjects,
                            selectedProjects: $selectedProjects,
                            isEditing: $isEditing
                        )
                    }
                }
                
                MainViewToolBar(
                    isEditing: $isEditing,
                    selectedProjects: $selectedProjects
                )
                
                if isShowingCodeSheet {
                        InviteCodeInputView(isShowingCodeSheet: $isShowingCodeSheet)
                            .zIndex(1000) // 항상 위에 떠야 하므로 높은 zIndex
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden)
        }
    }
    //MARK: - 코드참여버튼
    private var codeInputButton: some View {
        Button {
            isShowingCodeSheet = true
        } label: {
            Text("코드로 참여하기")
                .foregroundStyle(.primary1)
                .bold()
        }
        .buttonStyle(.plain)
        .padding(.vertical, 15)
        .padding(.horizontal, 26)
        .background(.secondary4)
        .cornerRadius(36)
        .shadow(color: .gray.opacity(0.4),
                radius: 6, x: 0, y: 0)
    }
}

// 샘플 데이터용 ID를 String으로 변환
var sampleProjects: [Project] = {
    var p1 = Project(
        title: "TPAP 우정 여행",
        tripType: .overnightTrip,
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
    )
    p1.id = "sample-1"
    
    var p2 = Project(
        title: "퍼스널 크루 여행",
        tripType: .dayTrip,
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
    )
    p2.id = "sample-2"
    
    var p3 = Project(
        title: "퍼스널 크루 여행",
        tripType: .dayTrip,
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
    )
    p3.id = "sample-3"
    
    return [p1, p2, p3]
}()

#Preview(traits: .landscapeLeft) {
    BlockView()
        .environmentObject(PlanManager())
        .environmentObject(RouteManager())
}
