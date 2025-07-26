import MapKit


protocol POISearchRepositoryProtocol {
    func searchPOIs(for query: String, region: MKCoordinateRegion, completion: @escaping ([MKMapItem]) -> Void)
}

