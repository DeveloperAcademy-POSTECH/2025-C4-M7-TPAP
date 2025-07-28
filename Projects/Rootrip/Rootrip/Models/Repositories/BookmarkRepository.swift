//
//  BookmarkRepository.swift
//  Rootrip
//
//  Created by POS on 7/20/25.
//

import FirebaseFirestore
import Foundation

final class BookmarkRepository: BookmarkRepositoryProtocol {
    private let db = Firestore.firestore()
    private let bookmarkRef = Firestore.firestore().collection("bookmarks")
    private let projectRef = Firestore.firestore().collection("Rootrip")

    func createBookmark(projectID: String, title: String, isDefault: Bool)
        async throws
    {
        let projectRef = db.collection("Rootrip").document(projectID)
        let bookmarkRef = projectRef.collection("bookmarks")

        let bookmark = Bookmark(
            projectID: projectID,
            title: title,
            isDefault: isDefault
        )
        try bookmarkRef.addDocument(from: bookmark)
    }

    func addMapDetail(projectID: String, bookmarkID: String) async throws {

    }
    func loadBookmark(projectID: String, bookmarkID: String) async throws -> [MapDetail] {
        let ref = Firestore.firestore()
            .collection("Rootrip")
            .document(projectID)
            .collection("bookmarks")
            .document(bookmarkID)
            .collection("mapDetails")

        let snapshot = try await ref.getDocuments()
        let details: [MapDetail] = try snapshot.documents.map { doc in
            var detail = try doc.data(as: MapDetail.self)
            detail.id = doc.documentID
            return detail
        }
        return details
    }

    func updateBookmark(projectID: String, bookmark: Bookmark) async throws {

    }
    func findTarget(projectID: String, bookmarkID: String) async throws
        -> Bookmark?
    {
        let docRef = db.collection("Rootrip")
            .document(projectID)
            .collection("bookmarks")
            .document(bookmarkID)

        let docSnap = try await docRef.getDocument()
        return try docSnap.data(as: Bookmark.self)
    }
    func deleteBookmark(projectID: String, bookmarkID: String) async throws {
        do {
            guard
                let bookmark = try await findTarget(
                    projectID: projectID,
                    bookmarkID: bookmarkID
                )
            else {
                print("deleteBookmark Error - can't find target")
                return
            }

            if bookmark.isDefault {
                print("deleteBookmark Error - can't delete default bookmark")
                return
            }
            // TODO: Bookmark안에 MapDetail이 있는경우 default 북마크에 포함시키기
            //

            let bookmarkRef = db.collection("Rootrip")
                .document(projectID)
                .collection("bookmarks")
                .document(bookmarkID)

            try await bookmarkRef.delete()
        } catch {
            print("deleteBookmark Error -", error)
        }
    }
    func deleteMapDetail(projectID: String, bookmarkID: String) async throws {

    }
}
