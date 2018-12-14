//
//  SearchRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class SearchRouter {
    
    var viewController: SearchViewController?
    
    func showViewInboxEmailViewController(message: EmailMessage) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ViewInboxEmailStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ViewInboxEmailViewControllerID) as! ViewInboxEmailViewController
        vc.message = message
        vc.messageID = message.messsageID
        vc.currentFolderFilter = message.folder
        //vc.mailboxesList = (self.viewController?.mailboxesList)!
        vc.user = (self.viewController?.user)!
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }

}
