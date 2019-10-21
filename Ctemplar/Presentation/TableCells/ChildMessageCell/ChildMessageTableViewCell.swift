//
//  ChildMessageTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class ChildMessageTableViewCell: UITableViewCell {
    
    var parentController : ViewInboxEmailDataSource?
    
    @IBOutlet weak var senderLabel     : UILabel!
    @IBOutlet weak var headerLabel     : UILabel!
    @IBOutlet weak var bottomLine      : UIView!
    
    @IBOutlet weak var deleteLabel             : UILabel!
    @IBOutlet weak var leftLabel               : UILabel!
     
    @IBOutlet weak var timerlabelsView         : UIView!
    @IBOutlet weak var leftlabelView           : UIView!
    @IBOutlet weak var rightlabelView          : UIView!
    
    @IBOutlet var timerlabelsViewWidthConstraint        : NSLayoutConstraint!
    @IBOutlet var leftlabelViewWidthConstraint          : NSLayoutConstraint!
    @IBOutlet var rightlabelViewWidthConstraint         : NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(sender: String, header: String, message: EmailMessage, isLast: Bool) {
        
        self.senderLabel.text = sender
        self.headerLabel.text = header
        
        self.bottomLine.isHidden = !isLast
        
        self.setupPropertyLabel(message: message)
    }
    
    func setupPropertyLabel(message: EmailMessage) {
        
        leftlabelView.isHidden = true
        
        if let delayedDelivery = message.delayedDelivery {
            leftlabelView.isHidden = false
            leftlabelView.backgroundColor = k_greenColor
            if  let date = parentController?.formatterService!.formatDestructionTimeStringToDate(date: delayedDelivery) {
                leftLabel.attributedText = date.timeCountForDelivery(short: false)
            } else {
                if let date = parentController?.formatterService!.formatDestructionTimeStringToDateTest(date: delayedDelivery) {
                    leftLabel.attributedText = date.timeCountForDelivery(short: false)
                } else {
                    leftLabel.attributedText = NSAttributedString(string: "Error")
                }
            }
        }
        
        if let deadManDuration = message.deadManDuration {
            leftlabelView.isHidden = false
            leftlabelView.backgroundColor = k_redColor
            if  let date = parentController?.formatterService!.formatDeadManDateString(duration: deadManDuration, short: false) {
                leftLabel.attributedText = date
            } else {
                leftLabel.attributedText = NSAttributedString(string: "Error")
            }
        }
  
        if let destructionDate = message.destructDay {
            rightlabelView.isHidden = false
            rightlabelView.backgroundColor = k_orangeColor
            if  let date = parentController?.formatterService!.formatDestructionTimeStringToDate(date: destructionDate) {
                deleteLabel.attributedText = date.timeCountForDestruct(short: false)
            } else {
                //print("erorr formatting destructionDate:", destructionDate)
                if let date = parentController?.formatterService!.formatDestructionTimeStringToDateTest(date: destructionDate) {
                    print("new format date:", date)
                    deleteLabel.attributedText = date.timeCountForDestruct(short: false)
                } else {
                    deleteLabel.attributedText = NSAttributedString(string: "Error")
                }
            }
        } else {
            rightlabelView.isHidden = true
        }
                
        leftlabelViewWidthConstraint.constant = k_deleteLabelWidth
        rightlabelViewWidthConstraint.constant = k_deleteLabelWidth
              
        if leftlabelView.isHidden {
            leftlabelViewWidthConstraint.constant = 0.0
        }

        if rightlabelView.isHidden {
            rightlabelViewWidthConstraint.constant = 0.0
        }
              
        timerlabelsViewWidthConstraint.constant = leftlabelViewWidthConstraint.constant + rightlabelViewWidthConstraint.constant
        
        self.layoutIfNeeded()
    }
}
