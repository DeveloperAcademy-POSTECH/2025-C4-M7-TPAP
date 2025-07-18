//
//  ProjectRepository.swift
//  Rootrip
//
//  Created by POS on 7/19/25.
//

import Foundation
import FirebaseFirestore

final class ProjectRepository: ProjectRepositoryProtocol {
    private let db = Firestore.firestore()
    private let projectsCollection = "projects"  // DB name for firebase

    func createProject(_ project: Project) async throws {
        var newProject = project
        newProject.plans = []
        newProject.bookmarks = []

        let projectReference = try await db.collection(projectsCollection)
            .addDocument(from: newProject)
        let projectID = projectReference.documentID

        // set default Plans
        switch newProject.tripType {
        case .dayTrip:
            for _ in 0..<2 {
                try await createPlan(
                    projectID: projectID,
                    plan: Plan(id: nil, title: "", mapDetails: [], strokes: [])
                )
            }
        case .overnightTrip:
            guard let endDate = newProject.endDate else {
                ///error처리하는 부분
                return
            }

            let dayCount =
                Calendar.current.dateComponents(
                    [.day],
                    from: newProject.startDate,
                    to: endDate
                ).day ?? 0
            for _ in 0..<max(dayCount, 1) {
                try await createPlan(
                    projectID: projectID,
                    plan: Plan(id: nil, title: "", mapDetails: [], strokes: [])
                )
            }
        }

        // set default Bookmark
        let defaultBookmark = Bookmark(id: nil, title: "내 보관함", mapDetails: []) // TODO: 임의로 넣어둔 이름이라 논의필요
        try await createBookmark(
            projectID: projectID,
            bookmark: defaultBookmark
        )
    }

    func updateProject(_ project: Project) async throws {
        // 1. 이름 수정
        // 2. 날짜 수정 (일자)
        // 2-1. 날짜 수정 (종료일 추가)
        // 2-2. 날짜 수정 (종료일 삭제)
    }
    func deleteProject(projectID: String) async throws {
        func deleteProject(projectID: String) async throws {
            let docReference = db.collection(projectsCollection).document(projectID)

            do {
                try await docReference.delete()
                print("deleteProject success - \(projectID)")
            } catch {
                print("deleteProject Error - \(projectID): \(error)")
                throw error
            }
        }
    }

    

    func saveProject() async throws {

    }
}
