//
//  UpgradeToPrimeView.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17.01.2019.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

protocol UpgradeToPrimeViewDelegate {
    func cancelAction()
}

class UpgradeToPrimeView: UIView {
    
    var delegate    : UpgradeToPrimeViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.addGestureRecognizer(freeSpaceViewGesture)
    }
    
    //MARK: - IBActions
    
    @IBAction func upgradeAction(_ sender: AnyObject) {
        
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        //delegate?.cancelAction()
        self.isHidden = true
    }
}
