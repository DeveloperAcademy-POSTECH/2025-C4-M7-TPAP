//
//  Plan.swift
//  Rootrip
//
//  Created by POS on 7/18/25.
//

import Foundation
import FirebaseFirestore

struct Plan: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var mapDetails: [MapDetail]
    var strokes: [StrokeData]
}
