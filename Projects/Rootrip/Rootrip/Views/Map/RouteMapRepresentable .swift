//
//  MapUIViewRepresentable.swift
//  utilPenTest
//
//  Created by MINJEONG on 7/14/25.
//

/// 이 파일은 SwiftUI에서 UIKit의 MKMapView를 사용하기 위한 UIViewRepresentable 래퍼입니다.
/// 사용자 입력을 바탕으로 지도에 경로(Polyline)를 표시하고, 예상 소요시간 등을 어노테이션으로 보여줍니다.

///UIKit의 MKMapView를 SwiftUI에서 쓰기 위한 래퍼
import SwiftUI
import MapKit
import CoreLocation

struct RouteMapRepresentable: UIViewRepresentable {
    @ObservedObject var mapState: RouteManager
    
    // MARK: - UIViewRepresentable
    /// MKMapView를 생성하고 UtilPen(Coordinator)의 델리게이트를 연결합니다.
    func makeUIView(context: Context) -> MKMapView {
        mapState.mapView.delegate = context.coordinator
        return mapState.mapView
    }
    
    // MARK: - Update UIView
    /// SwiftUI의 상태 변화에 따라 UIView를 갱신하는 메서드이나, 현재 별도 업데이트 로직은 없습니다.
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    // MARK: - Coordinator
    /// SwiftUI에서 UIKit 델리게이트(MKMapViewDelegate 등)를 사용하기 위한 Coordinator 객체를 생성합니다.
    func makeCoordinator() -> Coordinator {
        Coordinator(routeManager: mapState)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate{
        var routeManager: RouteManager
        
        init(routeManager: RouteManager) {
            self.routeManager = routeManager
            super.init()
        }
        
        // MARK: - MKMapViewDelegate
        /// MKOverlay 객체에 대응하는 렌더러를 반환합니다.
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: polyline)
                renderer.strokeColor = .accent1
                renderer.lineWidth = 8
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
                    hostingController.view.centerYAnchor.constraint(equalTo: annotationView.centerYAnchor)
                ])
                
                return annotationView
            } else {
                annotationView?.glyphText = "⭐️"
                annotationView?.markerTintColor = .systemIndigo
                return annotationView
            }
        }
    }
}
