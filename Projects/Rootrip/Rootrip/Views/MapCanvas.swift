import SwiftUI
import MapKit
import CoreLocation // 위치 서비스 사용을 위해 CoreLocation 임포트

// CLLocationManagerDelegate를 채택하여 위치 업데이트를 처리할 클래스
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager() // CLLocationManager 인스턴스 생성
    @Published var region = MKCoordinateRegion( // 현재 지도 영역을 나타내는 Published 변수
        center: CLLocationCoordinate2D(latitude: 36.014, longitude: 129.325), // 초기값 (포스텍 근처)
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // 초기 확대/축소 레벨
    )
    @Published var authorizationStatus: CLAuthorizationStatus // 위치 권한 상태를 나타내는 Published 변수

    override init() {
        // MARK: - Fix: Initialize @Published property before super.init()
        // _authorizationStatus는 @Published 래퍼의 실제 저장 공간에 접근합니다.
        // locationManager.authorizationStatus는 초기화 시점에 접근 가능합니다.
        _authorizationStatus = Published(initialValue: locationManager.authorizationStatus)
        
        super.init() // 모든 저장 프로퍼티가 초기화된 후에 super.init() 호출

        locationManager.delegate = self // 델리게이트 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 가장 높은 정확도 요청
        // authorizationStatus는 이미 위에서 초기화되었으므로 다시 할 필요 없습니다.
    }

    // 위치 권한 요청
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization() // 앱 사용 중에만 위치 권한 요청
    }

    // 현재 위치 업데이트 시작
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation() // 위치 업데이트 시작
    }

    // 현재 위치 업데이트 중지
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation() // 위치 업데이트 중지
    }

    // CLLocationManagerDelegate 메서드: 위치 권한 상태 변경 시 호출
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus // 변경된 권한 상태 업데이트
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 권한이 부여되면 위치 업데이트 시작
            startUpdatingLocation()
        case .denied, .restricted:
            // 권한이 거부되거나 제한되면 처리 (예: 사용자에게 알림)
            print("위치 권한이 거부되거나 제한되었습니다.")
        case .notDetermined:
            // 아직 결정되지 않은 경우 (requestWhenInUseAuthorization() 호출 필요)
            print("위치 권한이 아직 결정되지 않았습니다.")
        @unknown default:
            break
        }
    }

    // CLLocationManagerDelegate 메서드: 위치 업데이트 시 호출
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return } // 최신 위치 정보 가져오기

        // 새로운 위치로 지도 영역 업데이트
        region = MKCoordinateRegion(
            center: latestLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // 현재 위치로 이동 시 더 확대
        )
        // 위치를 한 번 업데이트했으면 더 이상 업데이트할 필요가 없을 경우 중지 (선택 사항)
        // stopUpdatingLocation()
    }

    // CLLocationManagerDelegate 메서드: 위치 업데이트 실패 시 호출
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
}

// 뷰 이름을 MapCanvas로 수정했습니다.
struct MapCanvas: View {
    @StateObject private var locationManager = LocationManager()
    @State var selectedType: String = "A"
    
    @Binding var showMapCanvas: Bool

    var body: some View {
        ZStack(alignment: .top){
            MapCanvasToolBar(showMapCanvas: $showMapCanvas).zIndex(1)
            Map(coordinateRegion: $locationManager.region, showsUserLocation: true) // MapKit 뷰
                .edgesIgnoringSafeArea(.all) // 화면 전체를 채우도록 설정
        }
        .onAppear {
            locationManager.requestLocationPermission()
        }
    }
}




//#Preview {
//    MapCanvas()
//}
