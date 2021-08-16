//
//  PackageCell.swift
//  Sub
//


import UIKit
import Utility

class PackageCell: UITableViewCell {
    static let CellIdentifier = "PackageCell"

    @IBOutlet var checkImgView : UIImageView!
    @IBOutlet var packageName_LBl : UILabel!
    @IBOutlet var packageDesc_LBL : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        packageName_LBl.font = AppFont.medium.size(17)
        packageDesc_LBL.font = AppFont.medium.size(16)
        packageName_LBl.textColor = k_cellTitleTextColor
        packageDesc_LBL.textColor = k_cellSubTitleTextColor
        checkImgView.image = UIImage(named: "check")
        checkImgView.setImageColor(color: k_jpgColor)
        checkImgView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
