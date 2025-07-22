import FirebaseFirestore

final class ProjectInvitationRepository: ProjectInvitationProtocol {
    private let db = Firestore.firestore()

    func createInvitation(for projectID: String) async throws -> ProjectInvitation {
        let id = UUID().uuidString
        let invitation = ProjectInvitation(id: id, projectID: projectID, createdAt: Date())
        try await db.collection("ProjectInvitations").document(id).setData([
            "projectID": projectID,
            "createdAt": Timestamp(date: invitation.createdAt)
        ])
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
