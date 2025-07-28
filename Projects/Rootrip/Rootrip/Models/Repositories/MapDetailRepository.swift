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

    func loadMapDetailsFromPlan(projectID: String, containerID: String) async throws -> [MapDetail] {
        let ref = db.collection("Rootrip")
            .document(projectID)
            .collection("plans")
            .document(containerID)
            .collection("mapDetails")

        let snapshot = try await ref.getDocuments()
        let details: [MapDetail] = try snapshot.documents.map { doc in
            var detail = try doc.data(as: MapDetail.self)
            detail.id = doc.documentID
            return detail
        }
        return details
    }
    func loadMapDetailsFromBook(projectID: String, containerID: String) async throws -> [MapDetail] {
        let ref = db.collection("Rootrip")
            .document(projectID)
            .collection("bookmarks")
            .document(containerID)
            .collection("mapDetails")

        let snapshot = try await ref.getDocuments()
        let details: [MapDetail] = try snapshot.documents.map { doc in
            var detail = try doc.data(as: MapDetail.self)
            detail.id = doc.documentID
            return detail
        }
        return details
    }

    func addMapDetailToPlan(projectID: String, planID: String, detail: MapDetail) async throws {
        let ref = db.collection("Rootrip")
            .document(projectID)
            .collection("plans")
            .document(planID)
            .collection("mapDetails")

        try ref.addDocument(from: detail)
    }
    func addMapDetailToBook(projectID: String, bookmarkID: String, detail: MapDetail) async throws {
        let ref = db.collection("Rootrip")
            .document(projectID)
            .collection("bookmarks")
            .document(bookmarkID)
            .collection("mapDetails")

        try ref.addDocument(from: detail)
    }

    func deleteMapDetail(projectID: String, containerID: String, mapDetailID: String) async throws {
        let ref = db.collection("Rootrip")
            .document(projectID)
            .collection("plans")
            .document(containerID)
            .collection("mapDetails")
            .document(mapDetailID)

        try await ref.delete()
    }
}
