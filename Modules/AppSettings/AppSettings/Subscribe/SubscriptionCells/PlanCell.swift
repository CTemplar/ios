//
//  PlanCell.swift
//  Sub
//


import UIKit
import Utility


class PlanCell: UITableViewCell {
    static let CellIdentifier = "PlanCell"
    @IBOutlet var appName : UILabel!
    @IBOutlet var planName : UILabel!
    @IBOutlet var seperatorLBL : UILabel!
    @IBOutlet var forwardImgView : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        appName.textColor = k_cellSubTitleTextColor
        planName.textColor = k_redColor
        appName.font = AppFont.black.size(8)
        planName.font = AppFont.medium.size(17)
        seperatorLBL.backgroundColor = k_lightGrayColor
//        if let displayName = Bundle.main.displayName {
        self.appName.text = "Ctemplar".uppercased()
//        }
        forwardImgView.image = UIImage(named: "next")
        forwardImgView.setImageColor(color: k_lightGrayColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
