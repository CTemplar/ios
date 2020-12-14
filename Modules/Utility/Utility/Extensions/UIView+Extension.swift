import UIKit

public extension UIView {
    func parentView<T: UIView>(of type: T.Type) -> T? {
        guard let view = superview else {
            return nil
        }
        return (view as? T) ?? view.parentView(of: T.self)
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func applyDropShadow(shadowOpacity: Float = 0.7,
                         shadowColor: UIColor = k_shadowColor,
                         shadowRadius: CGFloat = 12.0,
                         shadowOffset: CGSize = CGSize(width: 0.0, height: 1.0)) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = 12.0
        layer.shadowOpacity = 0.7
    }
    
    func setBorder(color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}

