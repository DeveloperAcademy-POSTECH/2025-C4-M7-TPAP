//
//  PlanRepositoryProtocol.swift
//  Rootrip
//
//  Created by POS on 7/19/25.
//

import Foundation

protocol PlanRepositoryProtocol {
    /// add new Plan section
    func createPlan(projectID: String) async throws
    /// add sub-data
    func addMapDetail(projectID: String, plan: Plan) async throws
    func addStrokeData(projectID: String, planID: String) async throws
    
    /// read 'plans' data from firestore
    func loadPlan(projectID: String) async throws -> [Plan]
    /// modify MapDetails order and Plan title change
    func updatePlan(projectID: String, plan: Plan) async throws
    
    /// delete instance
    func deletePlan(projectID: String, planID: String) async throws
    /// delete sub-data
    func deleteMapDetail(projectID: String, plan: Plan) async throws
    func deleteStrokeData(projectID: String, planID: String) async throws
}
