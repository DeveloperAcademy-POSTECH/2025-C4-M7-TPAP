import MapKit

class POIAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let mapItem: MKMapItem

    init(mapItem: MKMapItem) {
        self.coordinate = mapItem.placemark.coordinate
        self.title = mapItem.name
        self.mapItem = mapItem
    }
}

