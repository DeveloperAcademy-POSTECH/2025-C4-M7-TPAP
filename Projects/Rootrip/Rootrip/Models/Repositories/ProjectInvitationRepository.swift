import FirebaseFirestore

final class ProjectInvitationRepository: ProjectInvitationProtocol {
    private let db = Firestore.firestore()

    func createInvitation(for projectID: String) async throws -> ProjectInvitation {
        // Step 1. 이미 존재하는 초대 코드가 있는지 확인
        let querySnapshot = try await db.collection("ProjectInvitations")
            .whereField("projectID", isEqualTo: projectID)
            .getDocuments()

        if let existingDoc = querySnapshot.documents.first {
            // 이미 존재하는 경우 → 해당 초대 코드 반환
            let data = existingDoc.data()
            let existingID = existingDoc.documentID
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            print("🔁 기존 초대 코드 반환: \(existingID)")
            return ProjectInvitation(id: existingID, projectID: projectID, createdAt: createdAt)
        }

        // Step 2. 없으면 새로 생성
        let id = UUID().uuidString
        let invitation = ProjectInvitation(id: id, projectID: projectID, createdAt: Date())

        try await db.collection("ProjectInvitations").document(id).setData([
            "projectID": projectID,
            "createdAt": Timestamp(date: invitation.createdAt)
        ])
        print("🆕 새 초대 코드 생성: \(id)")
        return invitation
    }

    func fetchInvitation(by id: String) async throws -> ProjectInvitation? {
        let snapshot = try await db.collection("ProjectInvitations").document(id).getDocument()
        guard let data = snapshot.data(),
              let projectID = data["projectID"] as? String,
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() else {
            return nil
        }
        return ProjectInvitation(id: id, projectID: projectID, createdAt: createdAt)
    }

    func deleteInvitation(id: String) async throws {
        try await db.collection("ProjectInvitations").document(id).delete()
    }
}
