//
//  FontResource.swift
//  Rootrip
//
//  Created by MINJEONG on 7/23/25.
//

import Foundation
import SwiftUI

extension Font {
    //MARK: 한글,영어,숫자
    enum Pre {
        case bold
        case semibold
        case regular
        case medium
        
        var value: String {
            switch self {
                /// SF Pro
            case .bold:
                return "Pretendard-Bold"
            case .semibold:
                return "Pretendard-SemiBold"
            case .regular:
                return "Pretendard-Regular"
            case .medium:
                return "Pretendard-Medium"
                
            }
        }
    }
    
    static func pre(type: Pre, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }
    
    //MARK: Pretendard Compact 변수들
    static var prebold32: Font {
        return .pre(type: .bold, size: 32)
    }
    static var presemi24: Font {
        return .pre(type: .semibold, size: 24)
    }
    static var presemi20: Font {
        return .pre(type: .semibold, size: 20)
    }
    static var presemi16: Font {
        return .pre(type: .semibold, size: 16)
    }
    static var premed16: Font {
        return .pre(type: .medium, size: 16)
    }
    static var prereg16: Font {
        return .pre(type: .regular, size: 16)
    }
    static var prebold12: Font {
        return .pre(type: .bold, size: 12)
    }
    static var premed12: Font {
        return .pre(type: .medium, size: 12)
    }
    static var presemi12: Font {
        return .pre(type: .semibold, size: 12)
    }
}
