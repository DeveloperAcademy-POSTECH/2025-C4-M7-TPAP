import SwiftUI
import UIKit
import MapKit
import CoreLocation

// MARK: - MapCoordinator
/// MKMapViewDelegate 구현 및 사용자 중심 초기화 상태 관리를 담당하는 Coordinator
class MapCoordinator: NSObject, MKMapViewDelegate {
    var hasCenteredOnUser = false
    var parent: MapView?
    var viewModel: MapViewModel

    init(parent: MapView, viewModel: MapViewModel) {
        self.parent = parent
        self.viewModel = viewModel
    }
    // MARK: - POI 어노테이션 선택 처리
    
    /// 어노테이션 뷰가 선택되었을 때 호출됩니다.
    /// - 인커밍: 선택된 POIAnnotation
    /// - 아웃고잉: CustomPOIDetailViewController를 팝오버로 표시
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let POIAnnotation = view.annotation as? POIAnnotation {
            let mapItem = POIAnnotation.mapItem
            let detailVC = CustomPOIDetailViewController(mapItem: mapItem)
            if let popover = detailVC.popoverPresentationController {
                popover.sourceView = view
                popover.sourceRect = view.bounds
                popover.permittedArrowDirections = [.up, .down]
            }
            if let topVC = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                .first?.topMostViewController() {
                topVC.present(detailVC, animated: true)
            }
        }
    }
    // MARK: - 지도 영역 변경 처리
    
    /// 지도 영역이 변경될 때 호출되어 어노테이션을 다시 추가하고 POI를 재검색합니다.
    /// - 인커밍: `mapView.region`
    /// - 아웃고잉: `viewModel.searchCommonPOIs(in:)` 호출, 이후 어노테이션 배열 순회하여 추가
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        viewModel.searchCommonPOIs(in: mapView.region)
        viewModel.poiAnnotations.forEach { annotation in
            mapView.addAnnotation(annotation)
        }
    }
    // MARK: - MKMapViewDelegate
    /// MKOverlay 객체에 대응하는 렌더러를 반환합니다.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 7
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    // MARK: - Custom Annotation(도보 및 장소 어노테이션)
    /// 어노테이션을 시각적으로 표현하기 위한 뷰(MKMarkerAnnotationView)를 구성합니다.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "WalkingTimeAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.markerTintColor = .systemIndigo
        } else {
            annotationView?.annotation = annotation
        }
        
        // 말풍선형 어노테이션
        // 기본 마커 대신 완전히 커스텀된 MKAnnotationView를 사용하여 SwiftUI 뷰를 붙입니다.
        if let title = annotation.title ?? "", title.hasPrefix("도보") {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            /// "도보" 문자열을 제거하고 실제 시간 텍스트만 추출
            let timeString = title.replacingOccurrences(of: "도보", with: "").trimmingCharacters(in: .whitespaces)
            
            /// SwiftUI의 TimeAnnotation 뷰를 UIKit에서 사용하기 위해 HostingController로 감쌉니다.
            /// 배경 투명 처리 및 오토레이아웃 설정을 위해 autoresizing mask 비활성화
            let hostingController = UIHostingController(rootView: TimeAnnotation(timeText: timeString))
            hostingController.view.backgroundColor = .clear
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            
            // SwiftUI 뷰를 어노테이션 뷰에 서브뷰로 추가합니다.
            annotationView.addSubview(hostingController.view)
            
            // SwiftUI 말풍선을 어노테이션 중심에 위치시키되, Y축을 위로 30pt 이동시켜 선 위에 오도록 배치합니다.
            NSLayoutConstraint.activate([
                hostingController.view.centerXAnchor.constraint(equalTo: annotationView.centerXAnchor),
                hostingController.view.centerYAnchor.constraint(equalTo: annotationView.centerYAnchor, constant: -30)
            ])
            
            return annotationView
        } else {
            annotationView?.glyphText = "⭐️"
            annotationView?.markerTintColor = .systemIndigo
            return annotationView
        }
    }
}

