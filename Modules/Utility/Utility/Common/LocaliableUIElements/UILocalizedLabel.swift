import UIKit

public class UILocalizedLabel: UILabel {
    public override func awakeFromNib() {
        super.awakeFromNib()
        text = text?.localized()
    }
}
