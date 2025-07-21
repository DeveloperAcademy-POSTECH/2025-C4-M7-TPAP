import SwiftUI

struct MainView: View {
    @State private var isEditing: Bool = false
    @State private var selectedProjects: Set<String> = []

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                //TODO: backgroundColor 추가해야함
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        Spacer()
                            .frame(height: 100)

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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden)
        }
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
    MainView()
        .environmentObject(PlanManager())
        .environmentObject(RouteManager())
}
