//
//  ViewInboxEmailViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ViewInboxEmailViewController: UIViewController {
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        
        let arrowBackImage = UIImage(named: k_darkBackArrowImageName)
        self.navigationController?.navigationBar.backIndicatorImage = arrowBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = arrowBackImage
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        
        let buttonWidth = 32.0
        
        let garbageButton : UIButton = UIButton.init(type: .custom)
        garbageButton.setImage(UIImage(named: k_garbageImageName), for: .normal)
        garbageButton.addTarget(self, action: #selector(garbageButtonPresed), for: .touchUpInside)
        garbageButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth)
        let garbageItem = UIBarButtonItem(customView: garbageButton)
        
        let spamButton : UIButton = UIButton.init(type: .custom)
        spamButton.setImage(UIImage(named: k_spamImageName), for: .normal)
        spamButton.addTarget(self, action: #selector(spamButtonPresed), for: .touchUpInside)
        spamButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth)
        let spamItem = UIBarButtonItem(customView: spamButton)
        
        let moveButton : UIButton = UIButton.init(type: .custom)
        moveButton.setImage(UIImage(named: k_moveImageName), for: .normal)
        moveButton.addTarget(self, action: #selector(moveButtonPresed), for: .touchUpInside)
        moveButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth)
        let moveItem = UIBarButtonItem(customView: moveButton)
        
        let moreButton : UIButton = UIButton.init(type: .custom)
        moreButton.setImage(UIImage(named: k_moreImageName), for: .normal)
        moreButton.addTarget(self, action: #selector(moreButtonPresed), for: .touchUpInside)
        moreButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth)
        let moreItem = UIBarButtonItem(customView: moreButton)
        
        self.navigationItem.rightBarButtonItems = [moreItem, moveItem, spamItem, garbageItem]
    }
    
    @objc func garbageButtonPresed() {
        
    }
    
    @objc func spamButtonPresed() {
        
    }
    
    @objc func moveButtonPresed() {
        
    }
    
    @objc func moreButtonPresed() {
        
    }
}

