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
    
    init(projectID: String, title: String) {
        self.id = nil
        self.projectID = projectID
        self.title = title
    }
}
//테스트용
extension Plan {
    init(id: String?, projectID: String, title: String) {
        self.id = id
        self.projectID = projectID
        self.title = title
    }
}
