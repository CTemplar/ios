import MaterialComponents.MaterialActivityIndicator
import UIKit

final class MatericalIndicator {
    static let shared = MatericalIndicator()
    private var activityIndicator: MDCActivityIndicator!
    
    private init() {
        activityIndicator = MDCActivityIndicator()
        activityIndicator.sizeToFit()
        setup()
    }
    
    @discardableResult
    func setup(with cycleColors: [UIColor] = [AppStyle.Colors.loaderColor.color,
                                              AppStyle.Colors.loaderColor.color,
                                              AppStyle.Colors.loaderColor.color,
                                              AppStyle.Colors.loaderColor.color]) -> MatericalIndicator {
        activityIndicator.cycleColors = cycleColors
        return self
    }
    
    func loader(in view: UIView? = nil) -> MDCActivityIndicator {
        if let view = view {
            view.addSubview(activityIndicator)
        }
        return activityIndicator
    }
    
    func loader(with size: CGSize) -> MDCActivityIndicator {
        activityIndicator.frame.size = size
        return activityIndicator
    }
}
