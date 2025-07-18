//
//  Plan.swift
//  Rootrip
//
//  Created by POS on 7/18/25.
//

import FirebaseFirestore
import Foundation

struct Plan: Identifiable, Codable {
    @DocumentID var id: String?
    var projectID: String
    var title: String

    var mapDetails: [MapDetail]
    var strokes: [StrokeData]

    init(projectID: String, title: String) {
        self.id = nil
        self.projectID = projectID
        self.title = title

        self.mapDetails = []
        self.strokes = []
    }
}
