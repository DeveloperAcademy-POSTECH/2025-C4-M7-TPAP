import MapKit

// MARK: - POISearchRepositoryProtocol
/// POI 검색 Repository의 프로토콜을 정의합니다.
/// 구현체는 이 프로토콜을 준수하여 키워드 및 지도 영역 기반으로 POI 검색 기능을 제공
protocol POISearchRepositoryProtocol {
    /// 키워드와 지도 영역을 기반으로 POI 검색을 실행하는 메서드
    /// - Parameters:
    ///   - query: 검색할 키워드 문자열
    ///   - region: 검색을 제한할 지도 영역 (MKCoordinateRegion)
    ///   - completion: 검색 결과인 MKMapItem 배열을 반환하는 클로저
    func searchPOIs(for query: String,
                    region: MKCoordinateRegion,
                    completion: @escaping ([MKMapItem]) -> Void)
}

