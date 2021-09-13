import UIKit
import KDLoadingHelperKit

public class Loader {
    public class func start(with color: UIColor = AppStyle.Colors.loaderColor.color, presenter: UIViewController? = nil) {
        if #available(iOS 13.0, *) {
            KDLoadingView.animate(blurStyle: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light,
                                  lineWidth: 5.0,
                                  size: 50.0,
                                  firstColor: color,
                                  secondColor: color,
                                  thirdColor: color,
                                  presentingVC: presenter
            )
        } else {
            // Fallback on earlier versions
            KDLoadingView.animate(blurStyle: .light,
                                  lineWidth: 5.0,
                                  size: 50.0,
                                  firstColor: color,
                                  secondColor: color,
                                  thirdColor: color,
                                  presentingVC: presenter
            )
        }
    }
    
    public class func stop(in presenter: UIViewController? = nil) {
        
        KDLoadingView.stop(in: presenter)
    }
}
