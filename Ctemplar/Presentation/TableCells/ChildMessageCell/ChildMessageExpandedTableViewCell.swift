//
//  ChildMessageExpandedTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 19.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class ChildMessageExpandedTableViewCell: UITableViewCell {
    
    var parentController : ViewInboxEmailDataSource?
    
    @IBOutlet weak var senderLabel     : UILabel!
    @IBOutlet weak var recieverLabel   : UILabel!
    @IBOutlet weak var dateLabel       : UILabel!
    @IBOutlet weak var detailsButton   : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(message: EmailMessage) {
        
        if let sender = message.sender {
            senderLabel.text = sender
        }
        
        if let reciever = message.receiver { //temp
            self.recieverLabel.text = "Reciever Temp Text"//reciever
        }
        
        if let createdDate = message.createdAt {            
            if  let date = parentController?.formatterService!.formatStringToDate(date: createdDate) {
                dateLabel.text = parentController?.formatterService!.formatCreationDate(date: date)
            }
        }
        
    }
}
