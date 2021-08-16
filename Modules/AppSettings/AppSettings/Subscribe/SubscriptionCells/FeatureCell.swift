//
//  FeatureCell.swift
//  Sub
//


import UIKit
import Utility

class FeatureCell: UITableViewCell {
    static let CellIdentifier = "FeatureCell"
    @IBOutlet var checkImgView : UIImageView!
    @IBOutlet var featureName_LBl : UILabel!
    @IBOutlet var leadingConstraint : NSLayoutConstraint!
    @IBOutlet var trailingConstraint : NSLayoutConstraint!
    @IBOutlet var seperatorLBL : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        featureName_LBl.font = AppFont.medium.size(15)
        featureName_LBl.textColor = k_cellSubTitleTextColor
        seperatorLBL.backgroundColor = k_lightGrayColor
        checkImgView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
