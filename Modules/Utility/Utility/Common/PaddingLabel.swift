import UIKit
public final class PaddingLabel: UILabel {
    // MARK: Properties
    @IBInspectable public var topInset: CGFloat = 5.0
    @IBInspectable public var bottomInset: CGFloat = 5.0
    @IBInspectable public var leftInset: CGFloat = 5.0
    @IBInspectable public var rightInset: CGFloat = 5.0
    
    // MARK: - Layout
    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    public override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}
