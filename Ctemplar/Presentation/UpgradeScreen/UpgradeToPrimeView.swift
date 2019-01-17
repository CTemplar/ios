//
//  UpgradeToPrimeView.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17.01.2019.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class UpgradeToPrimeView: UIView {

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
        
        if let url = URL(string: k_upgradeURL) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
 
        self.isHidden = true
    }
}
