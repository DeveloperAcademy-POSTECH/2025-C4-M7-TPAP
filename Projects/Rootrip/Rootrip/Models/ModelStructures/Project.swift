//
//  Project.swift
//  Rootrip
//
//  Created by POS on 7/18/25.
//

import FirebaseFirestore
import Foundation

enum TripType: String, Codable, CaseIterable {
    case dayTrip
    case overnightTrip
}

struct Project: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var title: String
    var createdDate: Date
    var startDate: Date
    var endDate: Date?
    var tripType: TripType
    var memberIDs: [String]        // 공동작업자들의 ID 리스트

    init(
        title: String,
        tripType: TripType,
        startDate: Date,
        endDate: Date? = nil,
        memberIDs: [String] = []
    ) {
        self.id = nil
        self.title = title
        self.tripType = tripType
        self.createdDate = Date()
        self.startDate = startDate
        self.endDate = endDate
        self.memberIDs = memberIDs
    }
}
