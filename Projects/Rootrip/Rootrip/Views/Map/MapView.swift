import SwiftUI
import MapKit
import CoreLocation
import Foundation
import Contacts
import Combine



struct MapView: UIViewRepresentable {
    @ObservedObject private var locationManager = LocationManager()
    var viewModel: MapViewModel
    @Binding var shouldCenterOnUser: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        mapView.pointOfInterestFilter = .excludingAll
        
        return mapView
    }


    func updateUIView(_ uiView: MKMapView, context: Context) {
        if shouldCenterOnUser, let location = locationManager.location {
            let region = viewModel.region(for: location.coordinate)
            uiView.setRegion(region, animated: true)
            DispatchQueue.main.async {
                self.shouldCenterOnUser = false
            }
        } else if let location = locationManager.location,
                  !context.coordinator.hasCenteredOnUser {
            let region = viewModel.region(for: location.coordinate)
            uiView.setRegion(region, animated: true)
            context.coordinator.hasCenteredOnUser = true
        }
    }

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(parent: self, viewModel: viewModel)
    }
}


