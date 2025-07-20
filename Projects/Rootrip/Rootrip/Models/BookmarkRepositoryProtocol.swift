//
//  BookmarkRepositoryProtocol.swift
//  Rootrip
//
//  Created by POS on 7/19/25.
//

import Foundation

protocol BookmarkRepositoryProtocol {
    /// add new Bookmark section
    func createBookmark(projectID: String, title: String, isDefault: Bool) async throws
    /// add MapDetail in existing bookmark
    func addMapDetail(projectID: String, bookmarkID: String) async throws
    
    /// change MapDetails order or Bookmark title
    func updateBookmark(projectID: String, bookmark: Bookmark) async throws
    
    /// find single specific 'bookmark' by its ID
    func findTarget(projectID: String, bookmarkID: String) async throws -> Bookmark?

    /// delete instance
    func deleteBookmark(projectID: String, bookmarkID: String) async throws
    /// delete MapDetail
    func deleteMapDetail(projectID: String, bookmarkID: String) async throws
    
}
