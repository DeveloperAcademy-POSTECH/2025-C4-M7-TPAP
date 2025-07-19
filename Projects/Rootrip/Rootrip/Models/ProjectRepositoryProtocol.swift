//
//  ProjectRepositoryProtocol.swift
//  Rootrip
//
//  Created by POS on 7/19/25.
//

import Foundation

protocol ProjectRepositoryProtocol {
    /// create new empty project. containing default Plans and Bookmarks
    func createProject(title: String?, tripType: TripType, startDate: Date, endDate: Date?, completion: @escaping (Project) -> Void) async throws
    /// generate Project title automatically
    func genTitle(base: String) async throws -> String
    /// modifiy on existing project : especially about StrokeData
    func updateProject(_ project: Project) async throws
    /// delete instance
    func deleteProject(projectID: String) async throws

    /// upload current instance data on firestore
    func saveProject() async throws
}
