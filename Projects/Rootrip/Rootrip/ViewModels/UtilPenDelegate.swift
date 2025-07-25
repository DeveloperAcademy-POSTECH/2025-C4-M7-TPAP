//
//  UtilpenDelegate.swift
//  utilPenTest
//
//  Created by POS on 7/12/25.
//

import Foundation
import CoreLocation

protocol UtilPenDelegate: AnyObject {
    func utilPenClassify(_ result: UtilPen.InputType)
}
