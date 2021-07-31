//
//  HeaderCell.swift
//  Sub
//


import UIKit
import Utility

class HeaderCell: UITableViewCell {
    static let CellIdentifier = "HeaderCell"

    @IBOutlet var planLBL : UILabel!
    @IBOutlet var appNameLBL : UILabel!
    @IBOutlet var logo_ImgView : UIImageView!
    @IBOutlet var featureLBL : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        appNameLBL.textColor = k_cellTitleTextColor
        appNameLBL.font = AppFont.heavy.size(17)
        if let displayName = Bundle.main.displayName {
            self.appNameLBL.text = displayName.uppercased()
        }
        planLBL.textColor = k_cellTitleTextColor
        planLBL.font = AppFont.heavy.size(10)
        featureLBL.textColor = k_cellTitleTextColor
        featureLBL.font = AppFont.heavy.size(10)
        featureLBL.text = "Top Features".uppercased()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func set(plan : String){
        let mainString = "\(plan) Top Features".uppercased()
        let stringToColor = plan
        let range = (mainString as NSString).range(of: stringToColor)

        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: k_jpgColor, range: range)
        planLBL.attributedText = mutableAttributedString
    }
}
