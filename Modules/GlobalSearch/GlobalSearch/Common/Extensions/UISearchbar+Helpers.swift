import UIKit
import Utility

extension UISearchBar {
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return searchTextField
        } else {
            if let textField = value(forKey: "searchField") as? UITextField {
                return textField
            }
            return nil
        }
    }
    
    private var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap{ $0 as? UIActivityIndicatorView }.first
    }
    
    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            if newValue {
                if activityIndicator == nil {
                    let newActivityIndicator = UIActivityIndicatorView(style: .medium)
                    newActivityIndicator.startAnimating()
                    newActivityIndicator.backgroundColor = .secondarySystemBackground
                    newActivityIndicator.color = AppStyle.Colors.loaderColor.color
                    newActivityIndicator.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    
                    textField?.leftView?.addSubview(newActivityIndicator)
                    
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    newActivityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                }
            } else {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}
