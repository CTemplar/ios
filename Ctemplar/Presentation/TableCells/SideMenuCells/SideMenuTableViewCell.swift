//
//  SideMenuTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 29.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class SideMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftSelectionView : UIView!
    @IBOutlet weak var iconImageView     : UIImageView!
    @IBOutlet weak var titleLabel        : UILabel!
    @IBOutlet weak var unreadCountLabel  : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupSideMenuTableCell(selected: Bool, iconName: String, title: String, unreadCount: Int) {
        
        if selected {
            self.backgroundColor = k_sideMenuSelectedCellBackgroundColor
        } else {
            self.backgroundColor = k_sideMenuCellBackgroundColor
        }
        
        self.leftSelectionView.isHidden = !selected
        self.iconImageView.image = UIImage(named: iconName)
        self.titleLabel.text = title
        self.unreadCountLabel.text = unreadCount.description
        
        if unreadCount > 0 {
            self.unreadCountLabel.isHidden = false
        } else {
            self.unreadCountLabel.isHidden = true
        }
    }
}
