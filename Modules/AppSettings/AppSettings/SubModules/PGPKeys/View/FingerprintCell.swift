//
//  FingerprintCell.swift
//  AppSettings
//

import UIKit

class FingerprintCell: UITableViewCell {

    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var keyTypeaLbl: UILabel!
    @IBOutlet weak var fingerprintLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.setupUI()
        
//        let shadowSize : CGFloat = 5.0
//        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
//                                                   y: -shadowSize / 2,
//                                                   width: self.backView?.frame.size.width ?? 0 + shadowSize,
//                                                   height: self.backView?.frame.size.height ?? 0 + shadowSize))
//        self.backView?.layer.masksToBounds = false
//        self.backView?.layer.shadowColor = UIColor.black.cgColor
//        self.backView?.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
//        self.backView?.layer.shadowOpacity = 0.5
//        self.backView?.layer.shadowPath = shadowPath.cgPath

//        self.privateKeyDown
    }
    
    func setupUI() {
        self.backView?.layer.cornerRadius = 5
        //self.backgroundView?.layer.masksToBounds = true
        self.primaryLabel?.layer.cornerRadius = 5
        self.primaryLabel?.layer.masksToBounds = true
       
        self.backView?.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.backView?.layer.shadowColor = UIColor(named: "textColorLbl")?.cgColor
        self.backView?.layer.shadowRadius = 4
        self.backView?.layer.shadowOpacity = 0.15
        self.backView?.layer.masksToBounds = false
        self.backView?.clipsToBounds = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
//        let hasUserInterfaceStyleChanged = previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false
//        if hasUserInterfaceStyleChanged {
//            searchTableView.reloadData()
//        }
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
