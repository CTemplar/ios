import UIKit

public extension UINavigationController {
    var prefersLargeTitle: Bool {
        get {
            return navigationBar.prefersLargeTitles
        } set {
            navigationBar.prefersLargeTitles = newValue
        }
    }
    
    func updateTintColor(_ tintColor: UIColor = AppStyle.Colors.loaderColor.color) {
        navigationBar.tintColor = tintColor
    }
    
    func updateBackgroundColor() {
        view.backgroundColor = .systemBackground
    }
}
