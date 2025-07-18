//
//  ProjectRepositoryProtocol.swift
//  Rootrip
//
//  Created by POS on 7/19/25.
//

import Foundation

protocol ProjectRepositoryProtocol {
    /// create new empty project. containing default Plans and Bookmarks
    func createProject(_ project: Project) async throws
    /// modifiy on existing project : especially about StrokeData
    func updateProject(_ project: Project) async throws
    /// delete instance
    func deleteProject(projectID: String) async throws

    /// upload current instance data on firestore
    func saveProject() async throws
}
