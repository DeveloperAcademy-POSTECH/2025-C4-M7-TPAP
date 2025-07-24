//
//  UtilPen.swift
//  utilPenTest
//
//  Created by POS on 7/12/25.
//
// TODO: PKStroke input에 따른 각 함수의 input값 수정(지금은 좌표의 개수로)

import Foundation
import MapKit
import CoreLocation

class UtilPen: ObservableObject {
    
    // MARK: - Delegate (선택)
    weak var delegate: UtilPenDelegate?
    
    // MARK: - InputType 정의
    enum InputType {
        case line(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D)
        case area(points: [CLLocationCoordinate2D])
    }

    // MARK: - Published Properties (SwiftUI 연동)
    @Published var lastInput: InputType?
    @Published var allInputs: [InputType] = []

    // MARK: - Input 처리
    func inputHandler(_ coords: [CLLocationCoordinate2D]) {
        guard let input = inputClassify(coords) else { return }
        lastInput = input
        allInputs.append(input)
    }

    // MARK: - 선/영역 분류
    private func inputClassify(_ coords: [CLLocationCoordinate2D]) -> InputType? {
        guard coords.count >= 2 else { return nil }
        if isClosedShape(first: coords.first!, last: coords.last!) {
            return .area(points: coords)
        } else {
            return .line(start: coords.first!, end: coords.last!)
        }
    }

    // MARK: - 지도 렌더링
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
                print("utilPen error: \(error?.localizedDescription ?? "unknown error on showRoute function")")
                completion(nil)
                return
            }
            mapView.addOverlay(route.polyline)
            
            // 중간 지점 계산
            let polylinePoints = route.polyline.points()
            let midPoint = polylinePoints[route.polyline.pointCount / 2].coordinate

            // 애노테이션 추가
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
        mapView.setVisibleMapRect(
            polygon.boundingMapRect,
            animated: true
        )
    }

    // MARK: - 입력이 닫힌 영역인지 판별
    private func isClosedShape(
        first: CLLocationCoordinate2D,
        last: CLLocationCoordinate2D
    ) -> Bool {
        let threshold: CLLocationDegrees = 0.0001
        return (abs(first.latitude - last.latitude) < threshold)
            && (abs(first.longitude - last.longitude) < threshold)
    }
    
    // MARK: - Zoom 등 추가 유틸(필요시)
    func zoomToRegion(containing coordinates: [CLLocationCoordinate2D], in mapView: MKMapView, animated: Bool = true) {
        guard !coordinates.isEmpty else { return }
        var rect = MKMapRect.null
        for coordinate in coordinates {
            let point = MKMapPoint(coordinate)
            rect = rect.union(MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0)))
        }
        mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 80, right: 40), animated: animated)
    }
}
