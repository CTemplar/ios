//
//  SettingsStorageTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 21.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class SettingsStorageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var valuesLabel        : UILabel!
    
    @IBOutlet weak var valueLineView      : UIView!
    @IBOutlet weak var backgroundLineView : UIView!
    
    @IBOutlet var valueLineViewWidthConstraint       : NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(usedStorageSpace: Int, totalStorageSpace: Int) {
        
        self.selectionStyle = .none
        
        self.setupValuesLabel(usedStorageSpace: usedStorageSpace, totalStorageSpace: totalStorageSpace)
         
        if usedStorageSpace > 0 {
            let ratio = CGFloat(totalStorageSpace/usedStorageSpace)
            let value = self.backgroundLineView.frame.width / ratio
            self.valueLineViewWidthConstraint.constant = value
        } else {
            self.valueLineViewWidthConstraint.constant = 0
        }
    }
    
    func setupValuesLabel(usedStorageSpace: Int, totalStorageSpace: Int) {
        
        let valuesText = self.formatValue(value: usedStorageSpace) + " / " + self.formatValue(value: totalStorageSpace)
        self.valuesLabel.text = valuesText
    }
    
    func formatValue(value: Int) -> String {
        
        var textValue = ""
        
        if value > 1000 {
            if value > 1000000 {
                //GB
                let valueInGigabytes = value/1024/1024
                textValue = valueInGigabytes.description + " GB"
            } else {
                //MB
                let valueInMegabytes = value/1024
                textValue = valueInMegabytes.description + " MB"
            }
        } else {
            //KB
            textValue = value.description + " KB"
        }
        
        return textValue
    }
}
