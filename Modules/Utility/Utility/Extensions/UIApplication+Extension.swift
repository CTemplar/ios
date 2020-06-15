import UIKit

public extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    class func openAppSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                  options: [:],
                                  completionHandler: { (enabled) in
            // ... handle if enabled
        })
    }
    
    class func openAppNotificationsSetting() {
        if let url = URL(string:"App-Prefs:root=NOTIFICATIONS_ID") {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func getKeyWindow() -> UIWindow? {
        let newWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        return newWindow
    }
}
