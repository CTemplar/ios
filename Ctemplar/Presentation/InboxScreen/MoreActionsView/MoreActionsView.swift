//
//  MoreActionsView.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 2.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility

protocol MoreActionsDelegate {
    func applyAction(_ sender: AnyObject, isButton: Bool)
}

class MoreActionsView: UIView {
    
    var delegate    : MoreActionsDelegate?
    
    @IBOutlet var upperButtonHeightConstraint           : NSLayoutConstraint!
    @IBOutlet var middleButtonHeightConstraint          : NSLayoutConstraint!
    @IBOutlet var buttonsViewHeightConstraint           : NSLayoutConstraint!
    
    @IBOutlet var upperButton     : UIButton!
    @IBOutlet var middleButton    : UIButton!
    @IBOutlet var bottomButton    : UIButton!
    @IBOutlet var cancelButton    : UIButton!
    
    @IBOutlet var freeSpaceView    : UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        self.isUserInteractionEnabled = true
    }
    
    func setup(buttonsNameArray: Array<String>) {
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.freeSpaceView.addGestureRecognizer(freeSpaceViewGesture)
        
        middleButton.isHidden = true
        upperButton.isHidden = true
        
        upperButtonHeightConstraint.constant = 0
        buttonsViewHeightConstraint.constant = k_moreActionsButtonsViewSmallContstraint
        
        bottomButton.setTitleColor(k_actionMessageColor, for: .normal)
        middleButton.setTitleColor(k_actionMessageColor, for: .normal)
        upperButton.setTitleColor(k_actionMessageColor, for: .normal)
        
        for (index, buttonName) in buttonsNameArray.enumerated() {
            
            if buttonName == "emptyFolder".localized() {
                bottomButton.setTitleColor(k_redColor, for: .normal)
            }
            
            if buttonName == "discardDraft".localized() {
                bottomButton.setTitleColor(k_redColor, for: .normal)
            }
            
            switch index + MoreViewButtonsTag.cancel.rawValue {
                
            case MoreViewButtonsTag.cancel.rawValue:
                cancelButton.isHidden = false
                cancelButton.setTitle(buttonName, for: .normal)
                break
            case MoreViewButtonsTag.bottom.rawValue:
                bottomButton.isHidden = false
                bottomButton.setTitle(buttonName, for: .normal)
                break
            case MoreViewButtonsTag.middle.rawValue:
                middleButton.isHidden = false
                buttonsViewHeightConstraint.constant = k_moreActionsButtonsViewMiddleContstraint
                middleButtonHeightConstraint.constant = k_moreActionsButtonHeightConstraint
                middleButton.setTitle(buttonName, for: .normal)
                break
            case MoreViewButtonsTag.upper.rawValue:               
                upperButton.isHidden = false
                buttonsViewHeightConstraint.constant = k_moreActionsButtonsViewFullContstraint
                upperButtonHeightConstraint.constant = k_moreActionsButtonHeightConstraint
                upperButton.setTitle(buttonName, for: .normal)
                break
            default:
                print("more actions setup: default")
            }
        }
        
        self.layoutIfNeeded()
    }
    
    //MARK: - IBActions
    
    @IBAction func tappedAction(_ sender: AnyObject) {
        delegate?.applyAction(sender, isButton: true)
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        delegate?.applyAction(sender, isButton: false)
    }
}
