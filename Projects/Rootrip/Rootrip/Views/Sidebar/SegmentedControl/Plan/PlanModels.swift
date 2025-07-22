//
//  PlanModels.swift
//  Sidebar
//
//  Created by MINJEONG on 7/18/25.
//

//import Foundation
//import CoreLocation
//import FirebaseFirestore
//
//// MARK: - 장소 단위 모델
///// 하나의 장소 정보를 나타냅니다.
//struct PlanPlace: Hashable, Identifiable, Codable {
//    @DocumentID var id: String?
//    var name: String
//    var latitude: Double
//    var longitude: Double
//    
//    var coordinate: CLLocationCoordinate2D {
//        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    }
//    
//    init(id: String? = nil, name: String, coordinate: CLLocationCoordinate2D) {
//        self.id = id
//        self.name = name
//        self.latitude = coordinate.latitude
//        self.longitude = coordinate.longitude
//    }
//}
//
//// MARK: - 섹션 단위 모델
///// 여러 장소를 담는 하나의 플랜 섹션입니다.
//struct PlanSection: Identifiable, Codable {
//    @DocumentID var id: String?
//    var title: String   // 예: "Plan A", "Plan B"
//    var places: [PlanPlace]
//}
//
//// MARK: - 샘플 데이터
///// 테스트용으로 사용할 샘플 장소들입니다.
//let samplePlaces: [PlanPlace] = [
//    PlanPlace(id: UUID().uuidString, name: "밥집 A", coordinate: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)),
//    PlanPlace(id: UUID().uuidString, name: "밥집 B", coordinate: CLLocationCoordinate2D(latitude: 37.5670, longitude: 126.9790)),
//    PlanPlace(id: UUID().uuidString, name: "밥집 C", coordinate: CLLocationCoordinate2D(latitude: 37.5675, longitude: 126.9800))
//]
//
//let samplePlacesB: [PlanPlace] = [
//    PlanPlace(id: UUID().uuidString, name: "카페 A", coordinate: CLLocationCoordinate2D(latitude: 37.5680, longitude: 126.9820)),
//    PlanPlace(id: UUID().uuidString, name: "서점 B", coordinate: CLLocationCoordinate2D(latitude: 37.5685, longitude: 126.9830)),
//    PlanPlace(id: UUID().uuidString, name: "공원 C", coordinate: CLLocationCoordinate2D(latitude: 37.5690, longitude: 126.9840))
//]
