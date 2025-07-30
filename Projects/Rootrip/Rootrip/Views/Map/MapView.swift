import SwiftUI
import MapKit
import CoreLocation
import Foundation
import Contacts
import Combine

/// UIViewRepresentable을 통해 UIKit의 MKMapView를 SwiftUI에서 사용하기 위한 구조체
struct MapView: UIViewRepresentable {
    // MARK: - 속성
    /// 위치 정보를 관리하는 매니저 (CoreLocation 사용)
    @EnvironmentObject var locationManager: LocationManager
    
    /// POI 어노테이션 및 지역 계산 로직을 가진 ViewModel
    var viewModel: MapViewModel
    
    /// 사용자를 화면 중앙에 맞출지 여부를 결정하는 바인딩 값
    @Binding var shouldCenterOnUser: Bool
    @Binding var mapView: MKMapView

    // MARK: - UIView 생성
    
    /// SwiftUI가 생성할 UIView 객체를 반환
    /// - 반환: 기본 설정된 MKMapView
    func makeUIView(context: Context) -> MKMapView {
        mapView.showsUserLocation = true              // 사용자 위치 표시
        mapView.delegate = context.coordinator         // Coordinator를 delegate로 지정
        mapView.pointOfInterestFilter = .excludingAll  // POI 기본 숨김
        mapView.mapType = .mutedStandard // 맵 색조 낮춤
        
        return mapView
    }

    // MARK: - UIView 업데이트
    
    /// SwiftUI 상태가 변경될 때 호출되어 MKMapView를 업데이트
    /// - 인커밍: `shouldCenterOnUser: Bool`, `locationManager.location: CLLocation?`
    /// - 아웃고잉: MKMapView의 표시 영역 (Region) 설정
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 사용자가 중앙 정렬을 요청한 경우
        if shouldCenterOnUser, let location = locationManager.location {
            let region = viewModel.region(for: location.coordinate)
            uiView.setRegion(region, animated: true)   // 지도 중앙 이동
            DispatchQueue.main.async {
                self.shouldCenterOnUser = false         // 요청 처리 후 플래그 리셋
            }
        }
        // 첫 로드 시 한 번만 중앙 정렬
        else if let location = locationManager.location,
                  !context.coordinator.hasCenteredOnUser {
            let region = viewModel.region(for: location.coordinate)
            uiView.setRegion(region, animated: true)
            context.coordinator.hasCenteredOnUser = true  // 중앙 정렬 완료 표시
        }
    }

    // MARK: - Coordinator 생성
    
    /// Coordinator 인스턴스를 생성하여 MKMapView의 Delegate 메서드를 처리
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self, viewModel: viewModel)
    }
}

