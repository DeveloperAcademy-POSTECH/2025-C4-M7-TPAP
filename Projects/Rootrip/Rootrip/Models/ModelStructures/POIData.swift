//
//  POIAnnotation.swift
//  Rootrip
//
//  Created by Ella's Mac on 7/29/25.
//

import Foundation
import MapKit

struct POIData: Identifiable {
    let id = UUID()
    let mapDetailID: String
    let name: String
    let keyword: String
    
    
    var imageName: String {
        switch keyword {
        case "cafe": return "graycafe"
        case "restaurant": return "grayrestaurant"
        default: return "graymap"
        }
    }
    
    var selectedImageName: String {
        switch keyword {
        case "cafe": return "greencafe"
        case "restaurant": return "greenrestaurant"
        default: return "greenmap"
        }
    }
}
