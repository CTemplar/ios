//
//  SideMenuTableSectionHeaderView.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 29.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
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
    
    func setupHeader(iconName: String, title: String, foldersCount: Int, hideBottomLine: Bool) {
        
        var folderText = "folders"
        
        if foldersCount == 1 {
            folderText = "folder"
        }
        
        let text: String = title + " (" + foldersCount.description + " " + folderText + ")"
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 14.0)!,
            .foregroundColor: k_sideMenuTextFadeColor,
            .kern: 0.0
            ])
        
        _ = attributedString.setForgroundColor(textToFind: title, color: k_sideMenuColor)
        _ = attributedString.setFont(textToFind: title, font: UIFont(name: k_latoRegularFontName, size: 16.0)!)
        
        self.iconImageView.image = UIImage(named: iconName)
       
        self.titleLabel.attributedText = attributedString
        self.bottomSeparatorView.isHidden = hideBottomLine
        self.backgroundColor = k_whiteColor
    }
}
