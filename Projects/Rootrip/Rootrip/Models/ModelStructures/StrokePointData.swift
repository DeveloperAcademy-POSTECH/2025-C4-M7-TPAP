//
//  StrokePointData.swift
//  Rootrip
//
//  Created by POS on 7/18/25.
//

import Foundation
import FirebaseFirestore

struct StrokePointData: Identifiable, Codable {
    @DocumentID var id: String?
    var x: Double
    var y: Double
    var lineWidth: Double //sizeWidth&sizeHeidht -> lineWidth 수정
}
