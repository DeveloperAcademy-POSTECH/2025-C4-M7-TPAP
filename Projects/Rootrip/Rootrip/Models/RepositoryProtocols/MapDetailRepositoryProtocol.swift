//
//  MapDetailRepositoryProtocol.swift
//  Rootrip
//
//  Created by POS on 7/19/25.
//

import Foundation

protocol MapDetailRepositoryProtocol {
    /// convert coordinates into MKMapItem
    func loadMapDetailsFromPlan(projectID: String, containerID: String) async throws -> [MapDetail]
    func loadMapDetailsFromBook(projectID: String, containerID: String) async throws -> [MapDetail]
    
    /// add new POI into plan/bookmark
    func addMapDetailToPlan(projectID: String, planID: String, detail: MapDetail) async throws
    func addMapDetailToBook(projectID: String, bookmarkID: String, detail: MapDetail) async throws
    
    /// delete POI from plan/bookmark
    func deleteMapDetail(projectID: String, containerID: String, mapDetailID: String)async throws
}
