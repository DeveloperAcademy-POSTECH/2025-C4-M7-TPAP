
import MapKit

// MARK: - POISearchRepository
/// POI 검색을 수행하는 Repository 클래스
class POISearchRepository: POISearchRepositoryProtocol {    
    /// 키워드와 지도 영역을 기반으로 POI 검색을 실행합니다.
    /// - Parameters:
    ///   - query: 검색할 자연어 키워드 문자열
    ///   - region: 검색을 제한할 지도 영역 (MKCoordinateRegion)
    ///   - completion: 검색 결과인 MKMapItem 배열을 반환하는 클로저
    func searchPOIs(for query: String,
                    region: MKCoordinateRegion,
                    completion: @escaping ([MKMapItem]) -> Void) {
        // MKLocalSearch 요청 생성
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query  // 검색 키워드 설정
        request.region = region              // 검색 영역 설정

        // 검색 실행
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            // response?.mapItems가 nil이면 빈 배열을 반환
            guard let items = response?.mapItems else {
                completion([])
                return
            }
            // 검색된 POI 결과 반환
            completion(items)
        }
    }
}

