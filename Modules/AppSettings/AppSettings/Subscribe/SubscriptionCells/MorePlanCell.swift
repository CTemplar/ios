//
//  MorePlanCell.swift
//  Sub
//


import UIKit
import Utility

protocol MoreDelegate:AnyObject {
    func moreTapped()
}
class MorePlanCell: UITableViewCell {
    static let CellIdentifier = "MorePlanCell"
    weak var delegate: MoreDelegate?
    @IBOutlet var moreBTN : UIButton!
    @IBOutlet var nextImgView : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        moreBTN.setTitleColor(k_jpgColor, for: .normal)
        moreBTN.titleLabel?.font = AppFont.heavy.size(12)
        moreBTN.setTitle("View all features".uppercased(), for: .normal)
        nextImgView.image = nextImgView.image?.withRenderingMode(.alwaysTemplate)
        nextImgView.tintColor = k_jpgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func moreAction (_ sender : UIButton){
        self.delegate?.moreTapped()
    }
    
}
