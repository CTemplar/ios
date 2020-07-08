import Foundation
import UIKit
import Utility

class CustomFolderTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var leftSelectionView : UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Setup
    func setupCustomFolderTableCell(selected: Bool, iconColor: String, title: String, unreadCount: Int) {
        backgroundColor = selected ? k_sideMenuSelectedCellBackgroundColor : k_sideMenuCellBackgroundColor
        leftSelectionView.isHidden = !selected
        
        let imageIcon = #imageLiteral(resourceName: "folderIcon").withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = UIColor.hexStringToUIColor(hex: iconColor)
        iconImageView.image = imageIcon
        titleLabel.text = title
        unreadCountLabel.text = unreadCount.description
        unreadCountLabel.isHidden = (unreadCount > 0) ? false : true
    }
}
