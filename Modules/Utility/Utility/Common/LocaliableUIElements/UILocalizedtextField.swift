import UIKit

public class UILocalizedTextField: UITextField {
    public override func awakeFromNib() {
        super.awakeFromNib()
        text = text?.localized()
        placeholder = placeholder?.localized()
    }
}
