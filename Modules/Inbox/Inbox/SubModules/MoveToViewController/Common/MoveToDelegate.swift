import Foundation

public protocol MoveToViewControllerDelegate: AnyObject {
    func didMoveMessage(to folder: String)
}
