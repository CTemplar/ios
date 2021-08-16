import Foundation
import UIKit
import Utility

class SideMenuTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var leftSelectionView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unreadCountLabel.isHidden = true
        leftSelectionView.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCell(selected: Bool,
                   icon: UIImage,
                   title: String,
                   unreadCount: Int) {
        backgroundColor = selected ? k_sideMenuSelectedCellBackgroundColor : k_sideMenuCellBackgroundColor
        
        leftSelectionView.isHidden = !selected
        if title.lowercased() == "subscriptions"{
            iconImageView.image = icon
            iconImageView.setImageColor(color: (self.traitCollection.userInterfaceStyle == .dark) ? UIColor.white : k_sideMenuColor)
        }else{
            iconImageView.image = icon
        }
        titleLabel.text = title
        unreadCountLabel.text = unreadCount.description
        unreadCountLabel.isHidden = (unreadCount > 0) ? false : true
    }
}
