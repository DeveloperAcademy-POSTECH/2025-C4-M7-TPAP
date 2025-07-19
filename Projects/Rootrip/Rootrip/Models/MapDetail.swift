//
//  MapDetail.swift
//  Rootrip
//
//  Created by POS on 7/18/25.
//

import Foundation
import FirebaseFirestore

struct MapDetail: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var latitude: Double
    var longitude: Double
}
