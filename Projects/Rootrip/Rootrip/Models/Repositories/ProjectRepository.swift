//
//  ProjectRepository.swift
//  Rootrip
//
//  Created by POS on 7/19/25.
//

import FirebaseFirestore
import Foundation

final class ProjectRepository: ProjectRepositoryProtocol {
    private let db = Firestore.firestore()
    private let projectsCollection = "Rootrip"  // DB name for firebase
    
    let baseTitle = "새 일정" // default 일정 이름. 다국어지원... 음.. 해야겠지?

    private let planRepository: PlanRepositoryProtocol
    private let bookmarkRepository: BookmarkRepositoryProtocol

    init(
        planRepository: PlanRepositoryProtocol = PlanRepository(),
        bookmarkRepository: BookmarkRepositoryProtocol = BookmarkRepository()
    ) {
        self.planRepository = planRepository
        self.bookmarkRepository = bookmarkRepository
    }

    func createProject(
        title: String?,
        tripType: TripType,
        startDate: Date,
        endDate: Date?,
        completion: @escaping (Project) -> Void
    ) async throws {
        /// if no 'endDate' though TripType == .overnightTrip
        guard !(tripType == .overnightTrip && endDate == nil) else {
            print("createProject Error - endDate required")
            return
        }
        
        /// if no 'title' input, auto generate project title
        let title_ = try await (title != nil ? title! : genTitle(base: baseTitle))

        let newProject = Project(
            title: title_,
            tripType: tripType,
            startDate: startDate,
            endDate: endDate
        )
                    
        let projectReference = try db.collection(projectsCollection)
            .addDocument(from: newProject)
        let projectID = projectReference.documentID

        // set default Plans
        var cnt = 0
        switch newProject.tripType {
        case .dayTrip:
            for _ in 0..<2 {
                try await planRepository.createPlan(projectID: projectID)
                cnt += 1
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
                try await planRepository.createPlan(projectID: projectID)
            }
        }

        // set default Bookmark
        let defaultTitle = "내 보관함"  // TODO: 임의로 넣어둔 이름이라 논의필요
        try await bookmarkRepository.createBookmark(
            projectID: projectID,
            title: defaultTitle,
            isDefault: true
        )
    }
    
    func genTitle(base: String) async throws -> String {
        let snapshot = try await db.collection(projectsCollection).getDocuments()
        let existingTitles = snapshot.documents.compactMap { $0["title"] as? String }

        if !existingTitles.contains(base) {
            return base
        }

        var i = 2
        while existingTitles.contains("\(base) (\(i))") {
            i += 1
        }

        return "\(base) (\(i))"
    }


    func updateProject(_ project: Project) async throws {
        // 1. 이름 수정
        // 2. 날짜 수정 (일자)
        // 2-1. 날짜 수정 (종료일 추가)
        // 2-2. 날짜 수정 (종료일 삭제)
    }
    
    func deleteProject(projectID: String) async throws {
        let projectRef = db.collection("Rootrip").document(projectID)

        // Delete Plans
        let plansSnapshot = try await projectRef.collection("plans").getDocuments()
        for doc in plansSnapshot.documents {
            try await doc.reference.delete()
        }

        // Delete Bookmarks
        let bookmarksSnapshot = try await projectRef.collection("bookmarks").getDocuments()
        for doc in bookmarksSnapshot.documents {
            try await doc.reference.delete()
        }

        // Delete Project
        try await projectRef.delete()
    }

    func saveProject() async throws {

    }
    
    func fetchAllProjects() async throws -> [Project] {
        print("🔍 Firestore에서 프로젝트 불러오기 시작...")
        
        let snapshot = try await db.collection(projectsCollection).getDocuments()
        print("🔍 Firestore 문서 개수: \(snapshot.documents.count)")
        
        var projects: [Project] = []
        
        for document in snapshot.documents {
            do {
                print("📄 문서 ID: \(document.documentID)")
                print("📄 문서 데이터: \(document.data())")
                
                let project = try document.data(as: Project.self)
                projects.append(project)
                print("✅ 프로젝트 변환 성공: \(project.title)")
            } catch {
                print("❌ 문서 변환 실패 (ID: \(document.documentID)): \(error)")
                continue
            }
        }
        
        print("🔍 총 변환된 프로젝트 수: \(projects.count)")
        return projects
    }
}
