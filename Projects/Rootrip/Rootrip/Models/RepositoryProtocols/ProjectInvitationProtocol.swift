import Foundation

protocol ProjectInvitationProtocol {
    /// 초대 코드 생성 함수
    func createInvitation(for projectID: String) async throws -> ProjectInvitation
    
    /// 코드에 해당하는 정보를 Firestore에서 가져오는 함수
    func fetchInvitation(by id: String) async throws -> ProjectInvitation?
    
    /// 코드 삭제 함수
    func deleteInvitation(id: String) async throws
}
