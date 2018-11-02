//
//  MoreActionsView.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 2.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

protocol MoreActionsDelegate {
    func applyAction(_ sender: AnyObject)
}

class MoreActionsView: UIView {
    
    var delegate    : MoreActionsDelegate?
    
    @IBOutlet var upperButtonHeightConstraint           : NSLayoutConstraint!
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
        
        upperButton.isHidden = true
        
        upperButtonHeightConstraint.constant = 0
        buttonsViewHeightConstraint.constant = k_moreActionsButtonsViewSmallContstraint
        
        for (index, buttonName) in buttonsNameArray.enumerated() {
            
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
        delegate?.applyAction(sender)
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        delegate?.applyAction(sender)
    }
}