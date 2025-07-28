//
//  ProjectRepositoryProtocol.swift
//  Rootrip
//
//  Created by POS on 7/19/25.
//

import Foundation

protocol ProjectRepositoryProtocol {
    /// create new empty project. containing default Plans and Bookmarks
    func createProject(title: String?, tripType: TripType, startDate: Date, endDate: Date?, userID: String ) async throws -> Project
    /// generate Project title automatically
    func genTitle(base: String) async throws -> String
    /// modifiy on existing project : especially about StrokeData
    func updateProject(_ project: Project) async throws
    /// delete instance
    func deleteProject(projectID: String) async throws

    /// upload current instance data on firestore
    func saveProject() async throws
    
    /// fetch all projects in Rootrip collection
    func fetchUserProjects(userID: String) async throws -> [Project]
    
    /// 작업자 추가하기
    func addMember(to projectID: String, userID: String) async throws
    
}
