import MapKit

class POISearchRepository: POISearchRepositoryProtocol {
    func searchPOIs(for query: String, region: MKCoordinateRegion, completion: @escaping ([MKMapItem]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let items = response?.mapItems else {
                completion([])
                return
            }
            completion(items)
        }
    }
}

