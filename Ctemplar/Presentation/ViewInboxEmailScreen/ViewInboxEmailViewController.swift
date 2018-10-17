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
        
        //let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        let garbage = UIBarButtonItem(image: UIImage(named: k_garbageImageName), style: .plain, target: self, action: nil)
        let spam = UIBarButtonItem(image: UIImage(named: k_spamImageName), style: .plain, target: self, action: nil)
        let move = UIBarButtonItem(image: UIImage(named: k_moveImageName), style: .plain, target: self, action: nil)
        let more = UIBarButtonItem(image: UIImage(named: k_moreImageName), style: .plain, target: self, action: nil)
        
        garbage.width = 32
        spam.width = 32
        move.width = 32
        more.width = 32
        
        self.navigationItem.rightBarButtonItems = [more, move, spam, garbage]
    }
}

