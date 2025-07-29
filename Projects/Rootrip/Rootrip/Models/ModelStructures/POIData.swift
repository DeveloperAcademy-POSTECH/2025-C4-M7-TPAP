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
        case "cafe":
            return "cup.and.saucer"
        case "restaurant":
            return "fork.knife"
        case "park":
            return "leaf"
        case "school":
            return "building.columns"
        default:
            return "mappin"
        }
    }
}
