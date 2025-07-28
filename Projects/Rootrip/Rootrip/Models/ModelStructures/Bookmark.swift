//
//  Bookmark.swift
//  Rootrip
//
//  Created by POS on 7/18/25.
//

import FirebaseFirestore
import Foundation

struct Bookmark: Identifiable, Codable {
    @DocumentID var id: String?
    var projectID: String
    var title: String
    var isDefault: Bool = false

    init(projectID: String, title: String, isDefault: Bool = false) {
        self.id = nil
        self.projectID = projectID
        self.title = title
        self.isDefault = isDefault
    }
}
//테스트용
extension Bookmark {
    init(id: String?, projectID: String, title: String, isDefault: Bool = false) {
        self.id = id
        self.projectID = projectID
        self.title = title
        self.isDefault = isDefault
    }
}
