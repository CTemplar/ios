//
//  SearchTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var folderNameBackground    : UIView!
    @IBOutlet weak var folderNameLabel         : UILabel!
    @IBOutlet weak var subjectLabel            : UILabel!
    @IBOutlet weak var dateLabel               : UILabel!
    @IBOutlet weak var senderLabel             : UILabel!
    
    @IBOutlet weak var hasAttachmentImageView  : UIImageView!
    @IBOutlet weak var isSecuredImageView      : UIImageView!
    @IBOutlet weak var isStaredImageView       : UIImageView!
    
    @IBOutlet var folderNameLabelWidthConstraint            : NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(message: EmailMessage) {
        
        
    }
}
