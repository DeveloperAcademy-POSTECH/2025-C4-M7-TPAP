import Foundation
import PencilKit
import CoreLocation
import MapKit

class MapCanvasViewModel: ObservableObject {
    let strokeRepository: StrokeRepositoryProtocol
    @Published var drawing: PKDrawing?
    @Published var lastSavedKey: String?
    @Published var isDrawing: Bool = false
    @Published var currentTool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    @Published var loadedRegionKeys: Set<String> = []

    init(strokeRepository: StrokeRepositoryProtocol) {
        self.strokeRepository = strokeRepository
    }

    func saveDrawing(for coordinates: [CLLocationCoordinate2D]) {
        if drawing == nil {
            print("⚠️ 저장 시도했지만 drawing이 nil입니다")
            return
        }
        print("💾 저장 시도 - 좌표 수: \(coordinates.count)")
        strokeRepository.save(drawing: drawing!, for: coordinates)
        let regionKey = makeRegionKey(from: coordinates)!
        lastSavedKey = regionKey
    }

    func loadDrawing(for coordinates: [CLLocationCoordinate2D]) {
        let regionKey = makeRegionKey(from: coordinates)!
        strokeRepository.loadAsync(for: coordinates) { drawing in
            if let drawing = drawing {
                self.drawing = drawing
                print("✅ 정확한 위치에서 드로잉 불러오기 성공 (key: \(regionKey))")
                NotificationCenter.default.post(name: Notification.Name("ApplyLoadedDrawing"), object: drawing)
            } else {
                print("🫥 해당 위치 드로잉 없음 (key: \(regionKey))")
            }
        }
    }

    func loadNearbyDrawing(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        self.drawing = strokeRepository.loadNearby(from: center, radius: radius)
    }

    func makeRegionKMK(center: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: center, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
    }
    
    func makeRegionKey(from coordinates: [CLLocationCoordinate2D]) -> String? {
        guard let first = coordinates.first else { return nil }
        let lat = Int(first.latitude * 1000)
        let lon = Int(first.longitude * 1000)
        return "\(lat)_\(lon)"
    }
}
