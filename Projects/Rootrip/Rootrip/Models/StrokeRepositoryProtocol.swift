import Foundation
import PencilKit
import CoreLocation

protocol StrokeRepositoryProtocol {
    
    func save(drawing: PKDrawing, for coordinates: [CLLocationCoordinate2D])
    
    func load(for coordinates: [CLLocationCoordinate2D]) -> PKDrawing?
    
    func loadNearby(from center: CLLocationCoordinate2D, radius: CLLocationDistance) -> PKDrawing?
    
    func loadAsync(for coordinates: [CLLocationCoordinate2D], completion: @escaping (PKDrawing?) -> Void)
}
