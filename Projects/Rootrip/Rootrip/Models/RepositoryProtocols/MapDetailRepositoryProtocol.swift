//
//  MapDetailRepositoryProtocol.swift
//  Rootrip
//
//  Created by POS on 7/19/25.
//

import Foundation

protocol MapDetailRepositoryProtocol {
    /// add new POI into plan/bookmark
    func addMapDetail(projectID: String, planID: String, detail: MapDetail) async throws
    
    /// convert coordinates into MKMapItem
    func loadMapDetails(projectID: String, planID: String) async throws -> [MapDetail]
    
    /// delete POI from plan/bookmark
    func deleteMapDetail(projectID: String, planID: String, mapDetailID: String)async throws
}
