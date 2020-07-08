import UIKit
import MaterialComponents

public class MatericalIndicator {
    public static let shared = MatericalIndicator()
    private var activityIndicator: MDCActivityIndicator!
    
    private init() {
        activityIndicator = MDCActivityIndicator()
        activityIndicator.sizeToFit()
        setup()
    }
    
    @discardableResult
    public func setup(with cycleColors: [UIColor] = [AppStyle.Colors.loaderColor.color,
                                              AppStyle.Colors.loaderColor.color,
                                              AppStyle.Colors.loaderColor.color,
                                              AppStyle.Colors.loaderColor.color]) -> MatericalIndicator {
        activityIndicator.cycleColors = cycleColors
        return self
    }
    
    public func loader(in view: UIView? = nil) -> MDCActivityIndicator {
        if let view = view {
            view.addSubview(activityIndicator)
        }
        return activityIndicator
    }
    
    public func loader(with size: CGSize) -> MDCActivityIndicator {
        activityIndicator.frame.size = size
        return activityIndicator
    }
    
    public func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    public func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}
