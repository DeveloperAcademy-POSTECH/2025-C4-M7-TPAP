import CoreLocation
import Foundation
import MapKit
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?

    weak var mapView: MKMapView?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func setMapView(_ mapView: MKMapView) {
        self.mapView = mapView
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        location = locations.first
    }

    // MARK: - 지도 경로 랜더링 및 도보 소요시간 반환
    /// MapKit 경로를 지도에 표시하고 예상 도보 시간을 반환
    func showRoute(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        on mapView: MKMapView,
        completion: @escaping (TimeInterval?) -> Void
    ) {
        guard let targetMapView = self.mapView else {
            completion(nil)
            return
        }

        let stt = MKPlacemark(coordinate: start)
        let end = MKPlacemark(coordinate: end)
        let sttItem = MKMapItem(placemark: stt)
        let endItem = MKMapItem(placemark: end)

        let request = MKDirections.Request()
        request.source = sttItem
        request.destination = endItem
        request.transportType = .walking

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                print(
                    "Route error: \(error?.localizedDescription ?? "unknown error on showRoute function")"
                )
                completion(nil)
                return
            }

            DispatchQueue.main.async {
                targetMapView.addOverlay(route.polyline)

                // 중간 지점 계산
                let polylinePoints = route.polyline.points()
                let midPoint = polylinePoints[route.polyline.pointCount / 2]
                    .coordinate

                // 소요시간 어노테이션 추가
                let annotation = MKPointAnnotation()
                annotation.coordinate = midPoint
                annotation.title = "도보 \(Int(route.expectedTravelTime / 60))분"
                targetMapView.addAnnotation(annotation)
            }

            completion(route.expectedTravelTime)
        }
    }

    // MARK: - Zoom 및 Shape 유틸리티
    func zoomToRegion(
        containing coordinates: [CLLocationCoordinate2D],
        animated: Bool = true
    ) {
        guard !coordinates.isEmpty else { return }

        guard let mapView = self.mapView else { return }

        var rect = MKMapRect.null
        for coordinate in coordinates {
            let point = MKMapPoint(coordinate)
            rect = rect.union(
                MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0))
            )
        }

        DispatchQueue.main.async {
            mapView.setVisibleMapRect(
                rect,
                edgePadding: UIEdgeInsets(
                    top: 80,
                    left: 40,
                    bottom: 80,
                    right: 40
                ),
                animated: animated
            )
        }

    }
}
