import UIKit
import KDLoadingView

public class Loader {
    public class func start(with color: UIColor = AppStyle.Colors.loaderColor.color) {
        KDLoadingView.animate(blurStyle: .extraLight, lineWidth: 5.0, size: 50.0, firstColor: color, secondColor: color, thirdColor: color)
    }
    
    public class func stop() {
        KDLoadingView.stop()
    }
}
