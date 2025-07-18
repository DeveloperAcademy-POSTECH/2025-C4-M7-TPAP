//
//  Bookmark.swift
//  Rootrip
//
//  Created by POS on 7/18/25.
//

import Foundation
import FirebaseFirestore

struct Bookmark: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var mapDetails: [MapDetail]
}
