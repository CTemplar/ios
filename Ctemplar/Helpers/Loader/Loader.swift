import UIKit
import KDLoadingView

class Loader {
    class func start(with color: UIColor = AppStyle.Colors.loaderColor.color) {
        KDLoadingView.animate(blurStyle: .extraLight, lineWidth: 5.0, size: 50.0, firstColor: color, secondColor: color, thirdColor: color)
    }
    class func stop() {
        KDLoadingView.stop()
    }
}
