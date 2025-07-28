//
//  MapDetailRepository.swift
//  Rootrip
//
//  Created by POS on 7/28/25.
//

import Foundation
import FirebaseFirestore

final class MapDetailRepository: MapDetailRepositoryProtocol {
    private let db = Firestore.firestore()

    func loadMapDetails(projectID: String, planID: String) async throws -> [MapDetail] {
        let ref = db.collection("Rootrip")
            .document(projectID)
            .collection("plans")
            .document(planID)
            .collection("mapDetails")

        let snapshot = try await ref.getDocuments()
        let details: [MapDetail] = try snapshot.documents.map { doc in
            var detail = try doc.data(as: MapDetail.self)
            detail.id = doc.documentID
            return detail
        }
        return details
    }

    func addMapDetail(projectID: String, planID: String, detail: MapDetail) async throws {
        let ref = db.collection("Rootrip")
            .document(projectID)
            .collection("plans")
            .document(planID)
            .collection("mapDetails")

        try ref.addDocument(from: detail)
    }

    func deleteMapDetail(projectID: String, planID: String, mapDetailID: String) async throws {
        let ref = db.collection("Rootrip")
            .document(projectID)
            .collection("plans")
            .document(planID)
            .collection("mapDetails")
            .document(mapDetailID)

        try await ref.delete()
    }
}
