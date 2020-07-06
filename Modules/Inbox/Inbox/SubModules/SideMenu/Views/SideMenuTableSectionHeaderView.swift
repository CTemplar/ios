import Foundation
import UIKit
import Utility

class SideMenuTableSectionHeaderView: UITableViewHeaderFooterView {

    // MARK: IBOutlets
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomSeparatorView: UIView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Setup
    func setupHeader(iconName: String, title: String, foldersCount: Int, hideBottomLine: Bool) {
        let folderText = foldersCount == 1 ? Strings.ManageFolder.folder.localized : Strings.ManageFolder.folders.localized

        let text: String = title + " (" + foldersCount.description + " " + folderText + ")"
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)!,
            .foregroundColor: k_sideMenuTextFadeColor,
            .kern: 0.0
            ])
        
        _ = attributedString.setForgroundColor(textToFind: title, color: k_sideMenuColor)
        _ = attributedString.setFont(textToFind: title, font: AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)!)
        
        iconImageView.image = UIImage(named: iconName)
       
        titleLabel.attributedText = attributedString
        bottomSeparatorView.isHidden = hideBottomLine
        backgroundColor = k_whiteColor
    }
}
