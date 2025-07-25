//
//  UtilPen.swift
//  utilPenTest
//
//  Created by POS on 7/12/25.
//

import CoreLocation
import Foundation
import MapKit

class UtilPen: ObservableObject {
    // MARK: - InputType 정의
    enum InputType {
        case line(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D)
        case area(points: [CLLocationCoordinate2D])
    }

    // MARK: - Published Properties (SwiftUI 연동)
    @Published var lastInput: InputType?
    @Published var allInputs: [InputType] = []

    // MARK: - Input 처리
    func lineHandler(_ coords: [CLLocationCoordinate2D], mapView: MKMapView) {
        guard coords.count >= 2 else { return }
        lastInput = .line(start: coords.first!, end: coords.last!)
        allInputs.append(lastInput!)
        showRoute(from: coords.first!, to: coords.last!, on: mapView) { _ in }
    }

    func areaHandler(_ coords: [CLLocationCoordinate2D], mapView: MKMapView) {
        guard coords.count >= 3 else { return }
        lastInput = .area(points: coords)
        allInputs.append(lastInput!)
        setArea(coords, in: mapView)
    }

    // MARK: - 지도 렌더링
    // TODO: 데이터 저장 로직 구문 추가
    func showRoute(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        on mapView: MKMapView,
        completion: @escaping (TimeInterval?) -> Void
    ) {
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
                    "utilPen error: \(error?.localizedDescription ?? "unknown error on showRoute function")"
                )
                completion(nil)
                return
            }
            // 지도에 경로를 '그리는' 부분. 이거 삭제하면 그림 안뜸
            mapView.addOverlay(route.polyline)

            // 어노테이션을 띄울 중간 지점 계산
            let polylinePoints = route.polyline.points()
            let midPoint = polylinePoints[route.polyline.pointCount / 2]
                .coordinate

            // TODO: 애노테이션 추가부분. 디자인 적용해야함
            let annotation = MKPointAnnotation()
            annotation.coordinate = midPoint
            annotation.title = "도보 \(Int(route.expectedTravelTime / 60))분"
            mapView.addAnnotation(annotation)

            completion(route.expectedTravelTime)
        }
    }

    // MARK: - 영역 지도 표시
    func setArea(_ points: [CLLocationCoordinate2D], in mapView: MKMapView) {
        guard points.count >= 3 else { return }
        let polygon = MKPolygon(coordinates: points, count: points.count)
        mapView.addOverlay(polygon)
        mapView.setVisibleMapRect(polygon.boundingMapRect, animated: true)
    }

    // MARK: - Zoom 등 추가 유틸(필요시)
    func zoomToRegion(
        containing coordinates: [CLLocationCoordinate2D],
        in mapView: MKMapView,
        animated: Bool = true
    ) {
        guard !coordinates.isEmpty else { return }
        var rect = MKMapRect.null
        for coordinate in coordinates {
            let point = MKMapPoint(coordinate)
            rect = rect.union(
                MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0))
            )
        }
        mapView.setVisibleMapRect(
            rect,
            edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 80, right: 40),
            animated: animated
        )
    }
}
