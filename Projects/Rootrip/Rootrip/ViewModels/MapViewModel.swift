import SwiftUI
import MapKit

/// MapKit POI 검색 및 어노테이션 관리를 담당하는 ViewModel
class MapViewModel: ObservableObject {
    // MARK: - 속성
    
    /// 지도에 표시되는 POI 어노테이션 배열
    /// - 타입: [POIAnnotation]
    @Published var poiAnnotations: [POIAnnotation] = []
    
    /// 현재 선택된 POI 항목. Map 뷰의 선택 메커니즘과 바인딩됨.
    /// - 타입: MKMapItem?
    @Published var selectedPOI: MKMapItem? = nil
    
    /// POI 검색을 수행하는 저장소
    private let poiSearchRepository: POISearchRepository
    
    // MARK: - 초기화
    
    /// POI 검색 저장소를 주입하여 ViewModel을 초기화합니다.
    /// - Parameter poiSearchRepository: POI 검색을 수행할 Repository
    init(poiSearchRepository: POISearchRepository = POISearchRepository()) {
        self.poiSearchRepository = poiSearchRepository
    }
    
    // MARK: - POI 검색 메서드
    
    /// 지정된 지역 내에서 키워드에 해당하는 POI를 검색합니다.
    /// 전달되는 데이터:
    ///   - 아웃고잉: `keyword: String`, `region: MKCoordinateRegion`
    ///   - 인커밍: completion 핸들러를 통해 전달되는 `[MKMapItem]`
    /// - Parameters:
    ///   - keyword: 검색할 키워드 (예: "restaurant", "cafe")
    ///   - region: 검색을 제한할 지도 영역
    ///   - completion: 검색된 POI 결과([MKMapItem])를 반환하는 클로저
    func searchPOIs(keyword: String, in region: MKCoordinateRegion, completion: @escaping ([MKMapItem]) -> Void) {
        poiSearchRepository.searchPOIs(for: keyword, region: region) { items in
            DispatchQueue.main.async {
                // items: 검색된 MKMapItem 배열
                completion(items)
            }
        }
    }
    
    // MARK: - 공통 POI 검색
    
    /// 미리 정의된 공통 POI 카테고리에 대해 순차적으로 검색을 수행합니다.
    /// 스로틀링을 위해 Dispatch 딜레이를 적용합니다.
    /// 전달되는 데이터:
    ///   - 아웃고잉: 키워드 배열([String])
    ///   - 인커밍: 각각의 키워드에 대해 검색된 `[MKMapItem]`을 POIAnnotation으로 변환
    /// - Parameter region: 검색을 제한할 지도 영역
    func searchCommonPOIs(in region: MKCoordinateRegion) {
        let keywords = ["restaurant", "food", "cafe", "bakery"]
        
        for (index, keyword) in keywords.enumerated() {
            let delay = DispatchTime.now() + .milliseconds(index * 300)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.searchPOIs(keyword: keyword, in: region) { items in
                    // MKMapItem을 POIAnnotation으로 변환
                    let newAnnotations = items.map { POIAnnotation(mapItem: $0, keyword: keyword) }
                    DispatchQueue.main.async {
                        // 어노테이션 배열에 추가
                        self.poiAnnotations.append(contentsOf: newAnnotations)
                    }
                }
            }
        }
    }
    
    // MARK: - 지역 계산 유틸리티
    
    /// 주어진 위치를 중심으로 MKCoordinateRegion을 생성
    /// 전달되는 데이터:
    ///   - 아웃고잉: `location: CLLocationCoordinate2D`, `meters: CLLocationDistance`
    ///   - 반환: `MKCoordinateRegion`
    /// - Parameters:
    ///   - location: 영역 중심 좌표
    ///   - meters: 위도/경도 스팬(미터 단위)
    /// - Returns: 구성된 MKCoordinateRegion
    func region(for location: CLLocationCoordinate2D,
                meters: CLLocationDistance = 1500) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: location,
                                  latitudinalMeters: meters,
                                  longitudinalMeters: meters)
    }
}

