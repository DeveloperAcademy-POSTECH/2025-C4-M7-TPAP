import SwiftUI
import MapKit


class MapViewModel: ObservableObject {
    @Published var poiAnnotations: [POIAnnotation] = []
    @Published var selectedPOI: MKMapItem? = nil
    
    private let poiSearchRepository: POISearchRepository

    init(poiSearchRepository: POISearchRepository = POISearchRepository()) {
        self.poiSearchRepository = poiSearchRepository
    }

    func searchPOIs(keyword: String, in region: MKCoordinateRegion, completion: @escaping ([MKMapItem]) -> Void) {
        poiSearchRepository.searchPOIs(for: keyword, region: region) { items in
            DispatchQueue.main.async {
                completion(items)
            }
        }
    }
    
    func searchCommonPOIs(in region: MKCoordinateRegion) {
            let keywords = ["restaurant", "food", "hospital", "school", "bank", "shopping", "hotel", "park", "cafe", "bakery"]

            for (index, keyword) in keywords.enumerated() {
                let delay = DispatchTime.now() + .milliseconds(index * 300)
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.searchPOIs(keyword: keyword, in: region) { items in
                        let newAnnotations = items.map { POIAnnotation(mapItem: $0) }
                        DispatchQueue.main.async {
                            self.poiAnnotations.append(contentsOf: newAnnotations)
                        }
                    }
                }
            }
        }

    func region(for location: CLLocationCoordinate2D, meters: CLLocationDistance = 1500) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: location, latitudinalMeters: meters, longitudinalMeters: meters)
    }
}

