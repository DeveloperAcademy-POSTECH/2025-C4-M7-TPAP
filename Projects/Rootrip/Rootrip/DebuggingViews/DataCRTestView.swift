//
//  DataCRTestView.swift
//  Rootrip
//
//  Created by POS on 7/18/25.
//

import SwiftUI

struct DataCRTestView: View {
    @State private var projects: [Project] = []
    @State private var plans: [Plan] = []
    @State private var bookmarks: [Bookmark] = []
    @State private var strokes: [StrokeData] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 16) {
                        Button("➕ Add Dummy Project") {
                            let newProject = Project(
                                title: "Summer Trip",
                                tripType: .overnightTrip,
                                startDate: Date(),
                                endDate: nil,
                            )
                            projects.append(newProject)
                        }

                        Button("➕ Add Dummy Plan") {
                            let detail = MapDetail(
                                id: UUID().uuidString,
                                name: "Camp Site",
                                latitude: 37.5,
                                longitude: 127.0
                            )
                            let newPlan = Plan(
                                projectID: UUID().uuidString,
                                title: "Day 1 Plan",
                            )
                            plans.append(newPlan)
                        }

                        Button("➕ Add Dummy Bookmark") {
                            let detail = MapDetail(
                                id: UUID().uuidString,
                                name: "Nice View",
                                latitude: 36.5,
                                longitude: 128.0
                            )
                            let newBookmark = Bookmark(
                                projectID: UUID().uuidString,
                                title: "Scenic Spot",
                            )
                            bookmarks.append(newBookmark)
                        }

                        Button("➕ Add Dummy Stroke") {
                            let point = StrokePointData(
                                id: UUID().uuidString,
                                x: 100.0,
                                y: 200.0,
                                sizeWidth: 1.5,
                                sizeHeight: 1.5
                            )
                            let newStroke = StrokeData(
                                id: UUID().uuidString,
                                isUtilPen: false,
                                isDeleted: false,
                                inkColor: [0.2, 0.5, 0.8, 1.0],
                                points: [point]
                            )
                            strokes.append(newStroke)
                        }
                    }
                }

                Divider()

                List {
                    Section(header: Text("Projects")) {
                        ForEach(projects) { project in
                            ProjectView(project: project)
                        }
                    }

//                    Section(header: Text("Plans")) {
//                        ForEach(plans) { plan in
//                            PlanView(plan: plan)
//                        }
//                    }
//
//                    Section(header: Text("Bookmarks")) {
//                        ForEach(bookmarks) { bm in
//                            BookmarkView(bookmark: bm)
//                        }
//                    }

                    Section(header: Text("Strokes")) {
                        ForEach(strokes) { stroke in
                            StrokeView(stroke: stroke)
                        }
                    }
                }
            }
            .navigationTitle("🔥 Firestore Debug")
            .padding()
        }
    }
}

// MARK: - Subviews

struct ProjectView: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading) {
            Text("📁 Title: \(project.title)")
            Text("ID: \(project.id ?? "nil")")
            Text("Created: \(project.createdDate.formatted())")
            Text("Start: \(project.startDate.formatted())")
            Text("End: \(project.endDate?.formatted() ?? "none")")
            Text("Trip Type: \(project.tripType.rawValue)")
        }
    }
}

//struct PlanView: View {
//    let plan: Plan
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("🗺️ Title: \(plan.title)")
//            Text("ID: \(plan.id ?? "nil")")
//            ForEach(plan.mapDetails) { detail in
//                Text(
//                    "- MapDetail: \(detail.name) (\(detail.latitude), \(detail.longitude))"
//                )
//            }
//            Text("Strokes: \(plan.strokes.count)")
//        }
//    }
//}
//
//struct BookmarkView: View {
//    let bookmark: Bookmark
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("🔖 Title: \(bookmark.title)")
//            ForEach(bookmark.mapDetails) { detail in
//                Text(
//                    "- MapDetail: \(detail.name) (\(detail.latitude), \(detail.longitude))"
//                )
//            }
//        }
//    }
//}

struct StrokeView: View {
    let stroke: StrokeData

    var body: some View {
        VStack(alignment: .leading) {
            Text("🖊️ Stroke with \(stroke.points.count) points")
            Text("isUtilPen: \(stroke.isUtilPen.description)")
            Text("isDeleted: \(stroke.isDeleted.description)")
            Text(
                "Ink Color: \(stroke.inkColor.map { String(format: "%.2f", $0) }.joined(separator: ", "))"
            )
            ForEach(stroke.points) { point in
                Text(
                    "- Point: (\(point.x), \(point.y)) Size: \(point.sizeWidth), \(point.sizeHeight)"
                )
            }
        }
    }
}
