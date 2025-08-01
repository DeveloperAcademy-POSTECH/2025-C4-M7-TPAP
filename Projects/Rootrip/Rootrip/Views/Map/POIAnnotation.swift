import MapKit

// MARK: - POIAnnotation
/// POIAnnotation 클래스는 MKMapItem 정보를 기반으로
/// 지도에 표시할 수 있는 어노테이션 객체를 생성
class POIAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let mapItem: MKMapItem
    let keyword: String  // NEW: Store the keyword used for this annotation

    init(mapItem: MKMapItem, keyword: String) {
        self.coordinate = mapItem.placemark.coordinate
        self.title = mapItem.name
        self.mapItem = mapItem
        self.keyword = keyword  // NEW: Save keyword
    }
}
