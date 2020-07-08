import UIKit

public class UILocalizedTextView: UITextView {
    public override func awakeFromNib() {
        super.awakeFromNib()
        text = text?.localized()
        let attributes = attributedText?.attributes(at: 0, effectiveRange: nil)
        attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}

