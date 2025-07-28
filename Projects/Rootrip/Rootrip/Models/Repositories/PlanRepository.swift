//
//  PlanRepository.swift
//  Rootrip
//
//  Created by POS on 7/19/25.
//

import FirebaseFirestore
import Foundation

final class PlanRepository: PlanRepositoryProtocol {
    private let db = Firestore.firestore()

    func createPlan(projectID: String) async throws {
        let projectRef = db.collection("Rootrip").document(projectID)
        let planRef = projectRef.collection("plans")

        let snapshot = try await projectRef.getDocument()
        guard let project = try? snapshot.data(as: Project.self) else {
            throw NSError(domain: "createPlan Error - Invalid Project", code: -1)
        }

        // auto title naming
        let newTitle: String
        switch project.tripType {
        case .dayTrip:
            let snapshot = try await planRef.getDocuments()
            let count = snapshot.documents.count
            let nextChar = UnicodeScalar("A".unicodeScalars.first!.value + UInt32(count))!
            newTitle = "Plan \(nextChar)"
        case .overnightTrip:
            let snapshot = try await planRef.getDocuments()
            let count = snapshot.documents.count
            newTitle = "Day \(count + 1)"
        }

        let newPlan = Plan(projectID: projectID, title: newTitle)
        try planRef.addDocument(from: newPlan)
    }
    func addMapDetail(projectID: String, plan: Plan) async throws{
        
    }
    func addStrokeData(projectID: String, planID: String) async throws{
        
    }
    func loadPlans(projectID: String) async throws -> [Plan] {
        let planRef = db.collection("Rootrip")
            .document(projectID)
            .collection("plans")
        
        let snapshot = try await planRef.getDocuments()
        
        let plans: [Plan] = try snapshot.documents.map { doc in
            var plan = try doc.data(as: Plan.self)
            plan.id = doc.documentID
            return plan
        }
        
        return plans
    }

    func updatePlan(projectID: String, plan: Plan) async throws {

    }
    
    func deletePlan(projectID: String, planID: String) async throws {
        let planRef = db.collection("Rootrip")
            .document(projectID)
            .collection("plans")
            .document(planID)

        try await planRef.delete()
    }
    func deleteMapDetail(projectID: String, plan: Plan) async throws {
        
    }
    func deleteStrokeData(projectID: String, planID: String) async throws {
        
    }

}
