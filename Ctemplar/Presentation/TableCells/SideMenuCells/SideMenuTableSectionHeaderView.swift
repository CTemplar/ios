//
//  SideMenuTableSectionHeaderView.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 29.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class SideMenuTableSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var iconImageView     : UIImageView!
    @IBOutlet weak var titleLabel        : UILabel!
    @IBOutlet weak var bottomSeparatorView      : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupHeader(iconName: String, title: String, hideBottomLine: Bool) {
        
        self.iconImageView.image = UIImage(named: iconName)
        self.titleLabel.text = title
        self.bottomSeparatorView.isHidden = hideBottomLine
        self.backgroundColor = k_whiteColor
    }
}
