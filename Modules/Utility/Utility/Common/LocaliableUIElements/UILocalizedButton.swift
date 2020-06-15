import UIKit

public class UILocalizedButton: UIButton {
    public override func awakeFromNib() {
        super.awakeFromNib()
        let title = self.title(for: .normal)?.localized()
        setTitle(title, for: .normal)
    }
}
