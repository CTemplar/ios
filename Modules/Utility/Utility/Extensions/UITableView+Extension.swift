import UIKit

public extension UITableViewCell {
    var tableView: UITableView? {
        return parentView(of: UITableView.self)
    }
}
