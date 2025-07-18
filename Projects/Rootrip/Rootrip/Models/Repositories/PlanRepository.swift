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
    private let planReference = Firestore.firestore().collection("plans")
    private let projectReference = Firestore.firestore().collection("projects")

    func createPlan(projectID: String, plan: Plan) async throws {
        let projectRef = db.collection("projects").document(projectID)

        try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let snapshot = try transaction.getDocument(projectRef)
                var project = try snapshot.data(as: Project.self)

                // auto title naming
                let newTitle: String
                switch project.tripType {
                case .dayTrip:
                    let nextChar = UnicodeScalar(
                        "A".unicodeScalars.first!.value
                            + UInt32(project.plans.count)
                    )!
                    newTitle = "Plan\(nextChar)"
                case .overnightTrip:
                    newTitle = "Day \(project.plans.count + 1)"
                }

                let newPlan = Plan(projectID: projectID, title: newTitle)

                project.plans.append(newPlan)
                try transaction.setData(from: project, forDocument: projectRef)
                return nil
            } catch let error {
                errorPointer?.pointee = error as NSError
                return nil
            }
        })
    }
    func updatePlan(projectID: String, plan: Plan) async throws {

    }
    func deletePlan(projectID: String, planID: String) async throws {

    }

}
