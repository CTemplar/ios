import UIKit

public extension CGRect {
    var minEdge: CGFloat {
        return min(width, height)
    }
}
