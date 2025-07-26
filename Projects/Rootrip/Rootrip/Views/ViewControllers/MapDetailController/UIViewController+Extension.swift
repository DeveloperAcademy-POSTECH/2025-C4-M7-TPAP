
import UIKit

// MARK: - UIViewController Extension
/// Extension으로 빼기에는 역할이 너무 붙어있어서 못 나눴어요..
extension UIViewController {
    // MARK: - 최상위 ViewController 조회
    /// 현재 ViewController에서 최상위(presented, navigation, tab) ViewController를 재귀적으로 찾아 반환
    /// - Returns: 최상위 UIViewController 인스턴스
    func topMostViewController() -> UIViewController {
        // presentedViewController가 있으면 재귀 호출하여 그 위로
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        // UINavigationController인 경우 visibleViewController를 탐색
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }
        // UITabBarController인 경우 선택된 ViewController를 탐색
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        // 그 외에는 self 반환
        return self
    }
}

