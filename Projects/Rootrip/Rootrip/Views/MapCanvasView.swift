import SwiftUI
import MapKit
import CoreLocation // 위치 서비스 사용을 위해 CoreLocation 임포트
import PencilKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - LocationManager (CLLocationManagerDelegate)
// CLLocationManagerDelegate를 채택하여 위치 업데이트를 처리할 클래스
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager() // CLLocationManager 인스턴스 생성
    @Published var region = MKCoordinateRegion( // 현재 지도 영역을 나타내는 Published 변수
        center: CLLocationCoordinate2D(latitude: 36.0190, longitude: 129.3435), // 포항
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
        // locationManager.requestLocation() // 현재 위치 요청 추가
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

    func requestLocation() {
        locationManager.requestLocation()
    }

    // CLLocationManagerDelegate 메서드: 위치 권한 상태 변경 시 호출
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus // 변경된 권한 상태 업데이트
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 권한이 부여되면 위치 업데이트 시작
            startUpdatingLocation()
            locationManager.requestLocation()
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
        guard let latestLocation = locations.last else { return }
        print("내 위치: \(latestLocation.coordinate.latitude), \(latestLocation.coordinate.longitude)")

        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: latestLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // 현재 위치로 이동 시 더 확대
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .refreshMapID, object: nil)
            }
        }
        // 위치를 한 번 업데이트했으면 더 이상 업데이트할 필요가 없을 경우 중지 (선택 사항)
        stopUpdatingLocation()
    }

    // CLLocationManagerDelegate 메서드: 위치 업데이트 실패 시 호출
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
}

// MARK: - MapViewContainer (UIViewRepresentable)
// MKMapView를 SwiftUI에서 사용하기 위한 UIViewRepresentable 래퍼
struct MapViewContainer: UIViewRepresentable {
    @Binding var mapView: MKMapView

    func makeUIView(context: Context) -> MKMapView {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 필요시 업데이트 구현
    }
}

// MARK: - RegionChangeHandler
// Helper class to handle region changes and load drawings
class RegionChangeHandler {
    static func handle(coordinateList: [CLLocationCoordinate2D], loadedRegionKeys: inout Set<String>, sharedMapView: MKMapView, strokeRepository: StrokeRepositoryProtocol) {
        for coordinate in coordinateList {
            let regionKey = "\(round(coordinate.latitude * 1000) / 1000)_\(round(coordinate.longitude * 1000) / 1000)"
            guard !loadedRegionKeys.contains(regionKey) else { continue }
            loadedRegionKeys.insert(regionKey)
            strokeRepository.loadAsync(for: [coordinate]) { drawing in
                if let drawing = drawing {
                    DispatchQueue.main.async {
                        if let canvasView = sharedMapView.subviews.compactMap({ $0 as? PKCanvasView }).first {
                            canvasView.drawing = drawing
                            print("드로잉 적용 완료 (key: \(regionKey))")
                        }
                    }
                } else {
                    print("해당 지역 드로잉 없음 (key: \(regionKey))")
                }
            }
        }
    }
}

// MARK: - MapCanvas View
// 뷰 이름을 MapCanvas로 수정했습니다.
struct MapCanvasView: View {
    let strokeRepository: StrokeRepositoryProtocol
    @StateObject private var locationManager = LocationManager()
    @State var selectedType: String = "A"
    
    @Binding var showMapCanvas: Bool
    
    @StateObject private var viewModel = MapCanvasViewModel(strokeRepository: FirebaseStrokeRepository.shared)
    
    @State private var showPermissionAlert = false
    @State private var regionID = UUID()
    @State private var isDrawing = false // 캔버스 활성 여부
    @State private var currentTool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    @State private var sharedMapView = MKMapView()
    
    // Add property to track loaded region keys
    @State private var loadedRegionKeys: Set<String> = []

    var currentRegion: MKCoordinateRegion {
        sharedMapView.region
    }

    var body: some View {
        // MARK: - Map and Drawing Layers
        ZStack(alignment: .top){
            MapCanvasToolBar(showMapCanvas: $showMapCanvas, isDrawing: $isDrawing, showSidebar: .constant(true), onSelectTool: { tool in
                currentTool = tool
                // Drawing should always be visible even for UtilPen
                isDrawing = true
            }).zIndex(2)
            
            MapViewContainer(mapView: $sharedMapView)
                .id(regionID)
                .edgesIgnoringSafeArea(.all)
                .onReceive(NotificationCenter.default.publisher(for: .MKMapViewRegionDidChangeAnimated)) { _ in
                    let center = sharedMapView.region.center
                    handleRegionDidChange(to: [center])
                }

            if isDrawing {
                DrawingCanvasView(
                    currentTool: currentTool,
                    currentRegion: sharedMapView.region,
                    isDrawing: $isDrawing,
                    mapView: sharedMapView,
                    onMappedCoordinates: { _ in },
                    onDrawingChanged: { updatedDrawing in
                        viewModel.drawing = updatedDrawing
                    },
                    onSaveDrawing: { coords in
                        viewModel.saveDrawing(for: [sharedMapView.region.center])
                    }
                )
                .edgesIgnoringSafeArea(.all)
                .zIndex(1)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        locationManager.startUpdatingLocation()
                    }) {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                            .padding()
                    }
                }
            }
        }
        .onAppear {
            if locationManager.authorizationStatus == .notDetermined {
                showPermissionAlert = true
            }
            let center = sharedMapView.region.center
            handleRegionDidChange(to: [center])
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshMapID)) { _ in
            regionID = UUID()
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("위치 권한 요청"),
                message: Text("이 앱은 지도를 표시하기 위해 위치 권한이 필요합니다."),
                primaryButton: .default(Text("허용"), action: {
                    locationManager.requestLocationPermission()
                }),
                secondaryButton: .cancel(Text("취소"))
            )
        }
        .onChange(of: isDrawing) { value in
            if value {
                if let key = viewModel.lastSavedKey {
                    let components = key.split(separator: "_").compactMap { Double($0) }
                    if components.count == 2 {
                        let coordinate = CLLocationCoordinate2D(latitude: components[0] / 1000, longitude: components[1] / 1000)
                        viewModel.loadDrawing(for: [coordinate])
                    }
                }
            }
        }
    }
    
    // MARK: - Region Change Trigger
    // Updated method to call RegionChangeHandler
    private func handleRegionDidChange(to coordinates: [CLLocationCoordinate2D]) {
        RegionChangeHandler.handle(coordinateList: coordinates, loadedRegionKeys: &loadedRegionKeys, sharedMapView: sharedMapView, strokeRepository: strokeRepository)
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let refreshMapID = Notification.Name("refreshMapID")
    static let MKMapViewRegionDidChangeAnimated = Notification.Name("MKMapViewRegionDidChangeAnimated")
}
