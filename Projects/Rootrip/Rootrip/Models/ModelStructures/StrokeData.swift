//
//  StrokeData.swift
//  Rootrip
//
//  Created by POS on 7/18/25.
//

import Foundation
import FirebaseFirestore

struct StrokeData: Identifiable, Codable {
    @DocumentID var id: String?
    var isUtilPen: Bool
    var isDeleted: Bool
    var inkColor: [Double]
    var points: [StrokePointData]
}
