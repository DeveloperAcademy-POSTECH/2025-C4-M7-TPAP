import Foundation
import FirebaseFirestore

struct ProjectInvitation: Identifiable, Codable {
    @DocumentID var id: String?             // 초대 코드
    var projectID: String                   // 프로젝트 ID
    var createdAt: Date                     // 생성 날짜

    init(id: String? = nil, projectID: String, createdAt: Date = Date()) {
        self.id = id
        self.projectID = projectID
        self.createdAt = createdAt
    }

   
    func toDictionary() -> [String: Any] {
        return [
            "projectID": projectID,
            "createdAt": Timestamp(date: createdAt)
        ]
    }

    static func from(document: DocumentSnapshot) -> ProjectInvitation? {
        guard let data = document.data(),
              let projectID = data["projectID"] as? String,
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() else {
            return nil
        }
        return ProjectInvitation(id: document.documentID, projectID: projectID, createdAt: createdAt)
    }
}
