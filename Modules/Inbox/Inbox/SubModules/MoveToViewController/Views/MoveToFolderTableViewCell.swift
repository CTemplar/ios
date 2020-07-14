import Foundation
import UIKit

class MoveToFolderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView     : UIImageView!
    @IBOutlet weak var titleLabel        : UILabel!
    @IBOutlet weak var checkImageView    : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupMoveToFolderTableCell(checked: Bool, iconColor: String, title: String, showCheckBox: Bool) {
        checkImageView.image = checked ? #imageLiteral(resourceName: "selectedRoundDark") : #imageLiteral(resourceName: "roundDark")
        checkImageView.isHidden = !showCheckBox
                
        let imageIcon = #imageLiteral(resourceName: "folderIcon").withRenderingMode(.alwaysTemplate)
        self.iconImageView.tintColor = self.hexStringToUIColor(hex: iconColor)
        self.iconImageView.image = imageIcon
                
        self.titleLabel.text = title
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
