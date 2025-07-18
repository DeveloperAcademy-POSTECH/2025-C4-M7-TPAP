//
//  BookmarkRepositoryProtocol.swift
//  Rootrip
//
//  Created by POS on 7/19/25.
//

import Foundation

protocol BookmarkRepositoryProtocol {
    /// add new Bookmark section
    func createBookmark(projectID: String, bookmark: Bookmark) async throws
    /// add or delete MapDetails, MapDetails order and Bookmark title change
    func updateBookmark(projectID: String, bookmark: Bookmark) async throws
    /// delete instance
    func deleteBookmark(projectID: String, bookmarkID: String) async throws
}
