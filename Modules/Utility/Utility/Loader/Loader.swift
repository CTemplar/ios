import UIKit
import KDLoadingView

public class Loader {
    public class func start(with color: UIColor = AppStyle.Colors.loaderColor.color) {
        if #available(iOS 13.0, *) {
            KDLoadingView.animate(blurStyle: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light,
                                  lineWidth: 5.0,
                                  size: 50.0,
                                  firstColor: color,
                                  secondColor: color,
                                  thirdColor: color
            )
        } else {
            // Fallback on earlier versions
            KDLoadingView.animate(blurStyle: .light,
                                  lineWidth: 5.0,
                                  size: 50.0,
                                  firstColor: color,
                                  secondColor: color,
                                  thirdColor: color
            )
        }
    }
    
    public class func stop() {
        KDLoadingView.stop()
    }
}
