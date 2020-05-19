//
//  SideMenuTableManageFolderCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 12.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit

class SideMenuTableManageFolderCell: UITableViewCell {
    
    @IBOutlet weak var leftSelectionView : UIView!
    @IBOutlet weak var iconImageView     : UIImageView!
    @IBOutlet weak var titleLabel        : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(selected: Bool, iconName: String, title: String, foldersCount: Int) {
        
        if selected {
            self.backgroundColor = k_sideMenuSelectedCellBackgroundColor
        } else {
            self.backgroundColor = k_sideMenuCellBackgroundColor
        }
        
        self.leftSelectionView.isHidden = !selected
        
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
        
        _ = attributedString.setForgroundColor(textToFind: title, color: k_folderCellTextColor)
        _ = attributedString.setFont(textToFind: title, font: UIFont(name: k_latoRegularFontName, size: 16.0)!)
        
        self.iconImageView.image = UIImage(named: iconName)
        
        self.titleLabel.attributedText = attributedString
    }
}
