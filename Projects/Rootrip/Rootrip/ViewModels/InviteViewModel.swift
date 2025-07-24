import Foundation
import FirebaseFirestore

class InviteViewModel: ObservableObject {
    private let repository: ProjectInvitationProtocol

    init(repository: ProjectInvitationProtocol = ProjectInvitationRepository()) {
        self.repository = repository
    }

    /// [1] 초대 코드 생성
    @MainActor
    func createInvitation(for projectID: String) async {
        do {
            let invitation = try await repository.createInvitation(for: projectID)
            print("✅ 초대 코드 생성 완료: \(invitation.id ?? "")")
        } catch {
            print("❌ 초대 코드 생성 실패: \(error.localizedDescription)")
        }
    }

    /// [2] 초대 코드로 프로젝트 참여 - 강화된 디버깅
    @MainActor
    func joinProject(with invitationID: String, currentUserID: String) async {
        print("🔍 joinProject 시작됨 with invitationID: \(invitationID)")

        do {
            // 1. 초대 코드 검증
            guard let invitation = try await repository.fetchInvitation(by: invitationID) else {
                print("❌ 유효하지 않은 초대 코드")
                return
            }
            print("📦 invitation.projectID = \(invitation.projectID)")

            // 2. Firebase 연결 상태 확인
            let db = Firestore.firestore()
            print("🔥 Firestore 인스턴스: \(db)")

            // 3. 컬렉션 존재 확인
            print("🔍 컬렉션 'Rootrip' 확인 중...")
            let collectionRef = db.collection("Rootrip")
            
            // 4. 전체 컬렉션 조회해보기
            let allDocs = try await collectionRef.limit(to: 5).getDocuments()
            print("📋 Rootrip 컬렉션의 문서 수: \(allDocs.documents.count)")
            for (index, doc) in allDocs.documents.enumerated() {
                print("  \(index). \(doc.documentID)")
            }

            // 5. 특정 문서 직접 조회
            let projectRef = collectionRef.document(invitation.projectID)
            print("🔍 프로젝트 문서 조회: \(projectRef.path)")
            
            let snapshot = try await projectRef.getDocument()
            print("📄 문서 존재 여부: \(snapshot.exists)")
            print("📊 문서 데이터 존재: \(snapshot.data() != nil)")
            
            if let data = snapshot.data() {
                print("📊 실제 데이터:")
                for (key, value) in data {
                    print("  \(key): \(type(of: value)) = \(value)")
                }
            }
            
            // 6. 문서가 존재하지 않는 경우
            guard snapshot.exists else {
                print("❌ 프로젝트가 존재하지 않습니다.")
                print("🔍 확인된 ProjectID: '\(invitation.projectID)'")
                print("🔍 문서 경로: \(projectRef.path)")
                
                // 비슷한 ID가 있는지 확인
                let similarDocs = allDocs.documents.filter { doc in
                    doc.documentID.contains(String(invitation.projectID.prefix(10)))
                }
                if !similarDocs.isEmpty {
                    print("🔍 비슷한 문서 ID들:")
                    for doc in similarDocs {
                        print("  - \(doc.documentID)")
                    }
                }
                return
            }

            // 7. Project 디코딩 시도
            print("🔄 Project 디코딩 시도 중...")
            
            do {
                let project = try snapshot.data(as: Project.self)
                print("✅ Project 디코딩 성공!")
                print("📝 Title: \(project.title)")
                print("👥 Members: \(project.memberIDs)")
                
                // 8. 멤버 추가 로직
                var updatedProject = project
                if !updatedProject.memberIDs.contains(currentUserID) {
                    updatedProject.memberIDs.append(currentUserID)
                    try projectRef.setData(from: updatedProject)
                    print("✅ 프로젝트 참여 완료")
                } else {
                    print("⚠️ 이미 참여 중인 사용자입니다.")
                }
                
            } catch let decodingError {
                print("❌ Project 디코딩 실패!")
                print("🔍 디코딩 오류: \(decodingError)")
                print("🔍 오류 타입: \(type(of: decodingError))")
                
                // 수동으로 데이터 확인
                if let data = snapshot.data() {
                    print("🔍 수동 필드 확인:")
                    print("  - id: \(data["id"] ?? "없음")")
                    print("  - title: \(data["title"] ?? "없음")")
                    print("  - createdDate: \(data["createdDate"] ?? "없음") (\(type(of: data["createdDate"])))")
                    print("  - startDate: \(data["startDate"] ?? "없음") (\(type(of: data["startDate"])))")
                    print("  - endDate: \(data["endDate"] ?? "없음") (\(type(of: data["endDate"])))")
                    print("  - tripType: \(data["tripType"] ?? "없음") (\(type(of: data["tripType"])))")
                    print("  - memberIDs: \(data["memberIDs"] ?? "없음") (\(type(of: data["memberIDs"])))")
                }
            }

        } catch let error {
            print("❌ 전체 오류 발생: \(error.localizedDescription)")
            print("🔍 오류 타입: \(type(of: error))")
            
            // NSError로 변환해서 더 자세한 정보 확인
            let nsError = error as NSError
            print("🔥 오류 도메인: \(nsError.domain)")
            print("🔥 오류 코드: \(nsError.code)")
            print("🔥 사용자 정보: \(nsError.userInfo)")
        }
    }
}
