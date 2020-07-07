import Foundation
import UIKit
import Utility

class SideMenuTableManageFolderCell: UITableViewCell {
    // MARK: IBOutlets
    @IBOutlet weak var leftSelectionView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Setup
    func setupCell(selected: Bool,
                   icon: UIImage,
                   title: String,
                   foldersCount: Int) {
        backgroundColor = selected ? k_sideMenuSelectedCellBackgroundColor : k_sideMenuCellBackgroundColor
        
        leftSelectionView.isHidden = !selected
        
        let folderText = foldersCount == 1 ? Strings.ManageFolder.folder.localized : Strings.ManageFolder.folders.localized
        
        let text: String = title + " (" + foldersCount.description + " " + folderText + ")"
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)!,
            .foregroundColor: k_sideMenuTextFadeColor,
            .kern: 0.0
            ])
        
        _ = attributedString.setForgroundColor(textToFind: title, color: k_folderCellTextColor)
        _ = attributedString.setFont(textToFind: title,
                                     font: AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)!)
        
        iconImageView.image = icon
        
        titleLabel.attributedText = attributedString
    }
}
