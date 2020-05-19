//
//  MoveToFolderTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 29.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

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
        
        if checked {
            checkImageView.image = UIImage(named: k_roundSelectedImageName)
        } else {
            checkImageView.image = UIImage(named: k_checkBoxUncheckedImageName)
        }
        
        checkImageView.isHidden = !showCheckBox
                
        let imageIcon = UIImage(named: k_folderIconImageName)?.withRenderingMode(.alwaysTemplate)
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
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
