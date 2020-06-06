import UIKit

extension CGRect {
    var minEdge: CGFloat {
        return min(width, height)
    }
}
