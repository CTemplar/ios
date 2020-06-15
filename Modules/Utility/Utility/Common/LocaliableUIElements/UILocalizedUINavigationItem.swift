import UIKit

public class UILocalizedUINavigationItem: UINavigationItem {
    public override func awakeFromNib() {
        super.awakeFromNib()
        title = title?.localized()
        leftBarButtonItem?.title = leftBarButtonItem?.title?.localized()
        rightBarButtonItem?.title = rightBarButtonItem?.title?.localized()
    }
}
