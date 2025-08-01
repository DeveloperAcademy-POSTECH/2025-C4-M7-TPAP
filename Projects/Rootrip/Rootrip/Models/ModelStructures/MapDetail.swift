//
//  MapDetail.swift
//  Rootrip
//
//  Created by POS on 7/18/25.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct MapDetail: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var containerID: String //Plan A, B 등 플랜 긴 구분에 관한 id(추가) + 어느 bookmark에 소속되어있는지도
    var name: String
    var latitude: Double
    var longitude: Double
}

//TODO: 좌표반환 함수는 나중에 만들어서 적용해야함
extension MapDetail {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}


//// MARK: - 샘플 플랜
//let samplePlans: [Plan] = [
//    Plan(id: "planA", projectID: "project1", title: "Plan A"),
//    Plan(id: "planB", projectID: "project1", title: "Plan B")
//]
//
//let sampleBookMarks: [Bookmark] = [
//    Bookmark(id: "bookmarkA", projectID: "project1", title: "식당"),
//    Bookmark(id: "bookmarkB", projectID: "project1", title: "카페")
//]
//
//// MARK: - 샘플 장소들
//let sampleMapDetails: [MapDetail] = [
//    MapDetail(id: "a1", planID: "planA", name: "밥집 A", latitude: 37.5665, longitude: 126.9780),
//    MapDetail(id: "a2", planID: "planA", name: "밥집 B", latitude: 37.5670, longitude: 126.9790),
//    MapDetail(id: "a3", planID: "planA", name: "밥집 C", latitude: 37.5675, longitude: 126.9800),
//    
//    MapDetail(id: "b1", planID: "planB", name: "카페 A", latitude: 37.5680, longitude: 126.9820),
//    MapDetail(id: "b2", planID: "planB", name: "서점 B", latitude: 37.5685, longitude: 126.9830),
//    MapDetail(id: "b3", planID: "planB", name: "공원 C", latitude: 37.5690, longitude: 126.9840)
//]
