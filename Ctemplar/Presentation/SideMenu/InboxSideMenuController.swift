//
//  InboxSideMenuController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 12.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import AlertHelperKit //temp

class InboxSideMenuController: UIViewController {
    
    @IBOutlet var emailLabel : UILabel!
    @IBOutlet var triangle   : UIImageView!
    
    @IBOutlet var triangleTrailingConstraint : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
 
        
        //self.view.backgroundColor = k_sideMenuColor
        
        self.navigationController?.navigationBar.isHidden = true
        
        //emailLabel.text = "xx@xx.com"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUserProfileBar()
    }
    
    func setupUserProfileBar() {
        
        let emailTextWidth = emailLabel.text?.widthOfString(usingFont: emailLabel.font)
        
        let triangleTrailingConstraintWidth = self.view.frame.width - emailTextWidth! - CGFloat(k_triangleOffset)
        updateTriangleTrailingConstraint(value: triangleTrailingConstraintWidth )
    }
    
    func updateTriangleTrailingConstraint(value: CGFloat) {
        
        DispatchQueue.main.async {
            self.triangleTrailingConstraint.constant = value
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func userProfilePressed(_ sender: AnyObject) {
        
        //temp: ======================
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let apiService: APIService? = appDelegate.applicationManager.apiService
        
        let params = Parameters(
            title: "",
            message: "Do you want to Logout?",
            cancelButton: "Cancel",
            otherButtons: ["Log Out"]
        )
        
        AlertHelperKit().showAlertWithHandler(self, parameters: params) { buttonIndex in
            switch buttonIndex {
            case 0:
                print("Cancel")
            default:
                print("LogOut")
                apiService?.logOut()  {(result) in
                    switch(result) {
                        
                    case .success(let value):
                        print("value:", value)
                     case .failure(let error):
                        print("error:", error)
                        
                    }
                }
            }
        }
        //=========================
    }
    
}
