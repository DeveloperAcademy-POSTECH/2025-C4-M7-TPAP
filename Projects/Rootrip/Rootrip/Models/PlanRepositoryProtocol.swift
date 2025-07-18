//
//  PlanRepositoryProtocol.swift
//  Rootrip
//
//  Created by POS on 7/19/25.
//

import Foundation

protocol PlanRepositoryProtocol {
    /// add new Plan section
    func createPlan(projectID: String, plan: Plan) async throws
    /// add or delete MapDetails, MapDetails order and Plan title change
    func updatePlan(projectID: String, plan: Plan) async throws
    /// delete instance
    func deletePlan(projectID: String, planID: String) async throws
}
