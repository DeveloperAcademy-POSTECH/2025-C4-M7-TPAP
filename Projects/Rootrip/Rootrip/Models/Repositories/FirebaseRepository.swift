import Foundation
import FirebaseFirestore
import PencilKit
import CoreLocation

final class FirebaseStrokeRepository: StrokeRepositoryProtocol {
    static let shared = FirebaseStrokeRepository()
    private init() {}

    func save(drawing: PKDrawing, for coordinates: [CLLocationCoordinate2D]) {
        guard let key = makeRegionKey(from: coordinates),
              let userID = getCurrentUserID(),
              let projectID = getCurrentProjectID() else { return }

        let data = drawing.dataRepresentation()
        let base64 = data.base64EncodedString()

        let db = Firestore.firestore()
        db.collection("users")
            .document(userID)
            .collection("projects")
            .document(projectID)
            .collection("strokes")
            .document(key)
            .setData(["drawing": base64]) { error in
                if let error = error {
                    print("Firebase 저장 오류: \(error.localizedDescription)")
                } else {
                    print("Firebase 드로잉 저장 완료 (key: \(key))")
                }
            }
    }

    func load(for coordinates: [CLLocationCoordinate2D]) -> PKDrawing? {
        print("Firebase는 동기 로딩을 지원하지 않음. loadAsync로")
        return nil
    }

    func loadNearby(from center: CLLocationCoordinate2D, radius: CLLocationDistance) -> PKDrawing? {
        print("Firebase는 반경 기반 탐색을 지원하지 않음.")
        return nil
    }

    /// 비동기 드로잉 불러오기 함수
    func loadAsync(for coordinates: [CLLocationCoordinate2D], completion: @escaping (PKDrawing?) -> Void) {
        guard let key = makeRegionKey(from: coordinates),
              let userID = getCurrentUserID(),
              let projectID = getCurrentProjectID() else {
            completion(nil)
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .document(userID)
            .collection("projects")
            .document(projectID)
            .collection("strokes")
            .document(key)
            .getDocument { snapshot, error in
                guard let document = snapshot, document.exists,
                      let base64 = document.data()?["drawing"] as? String,
                      let data = Data(base64Encoded: base64),
                      let drawing = try? PKDrawing(data: data) else {
                    print("드로잉 불러오기 실패 (key: \(key))")
                    completion(nil)
                    return
                }

                print("Firebase 드로잉 로드 완료 (key: \(key))")
                completion(drawing)
            }
    }
    
    /// 비동기 드로잉 불러오기 함수 (key로 직접 불러오기)
    func loadAsync(forKey key: String, completion: @escaping (PKDrawing?) -> Void) {
        guard let userID = getCurrentUserID(),
              let projectID = getCurrentProjectID() else {
            completion(nil)
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .document(userID)
            .collection("projects")
            .document(projectID)
            .collection("strokes")
            .document(key)
            .getDocument { snapshot, error in
                guard let document = snapshot, document.exists,
                      let base64 = document.data()?["drawing"] as? String,
                      let data = Data(base64Encoded: base64),
                      let drawing = try? PKDrawing(data: data) else {
                    print("드로잉 불러오기 실패 (key: \(key))")
                    completion(nil)
                    return
                }

                print("Firebase 드로잉 로드 완료 (key: \(key))")
                completion(drawing)
            }
    }
    
    func loadAsync(for regionKey: String, completion: @escaping (PKDrawing?) -> Void) {
        print("Firebase 드로잉 로드 시도 (key: \(regionKey))")
        let db = Firestore.firestore()
        let docRef = db.collection("drawings").document(regionKey)

        docRef.getDocument { (document, error) in
            if let error = error {
                print("Firebase 로드 실패: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let document = document, document.exists,
                  let data = document.data(),
                  let drawingData = data["drawing"] as? Data,
                  let drawing = try? PKDrawing(data: drawingData) else {
                print("해당 위치 드로잉 없음 (key: \(regionKey))")
                completion(nil)
                return
            }

            print("Firebase 드로잉 로드 성공 (key: \(regionKey))")
            completion(drawing)
        }
    }


    // MARK: - Helper

    private func makeRegionKey(from coordinates: [CLLocationCoordinate2D]) -> String? {
        guard let first = coordinates.first else { return nil }
        let lat = Int((first.latitude) * 1000)
        let lon = Int((first.longitude) * 1000)
        return "\(lat)_\(lon)"
    }

    private func getCurrentUserID() -> String? {
        // 사용자 ID를 반환 (예: Firebase Auth 기반)
        return "test-user-id" // 실제 구현에서는 Auth.auth().currentUser?.uid 등 사용
    }

    private func getCurrentProjectID() -> String? {
        // 현재 선택된 프로젝트 ID 반환
        return "test-project-id"
    }
}
