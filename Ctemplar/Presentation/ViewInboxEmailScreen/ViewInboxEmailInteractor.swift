//
//  ViewInboxEmailInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit

class ViewInboxEmailInteractor {
    
    var viewController      : ViewInboxEmailViewController?
    var presenter           : ViewInboxEmailPresenter?
    var apiService          : APIService?
    var pgpService          : PGPService?
    var formatterService    : FormatterService?
    

    func extractMessageContent(message: EmailMessage) -> String {
        
        if let content = message.content {            
            if let message = self.pgpService?.decryptMessage(encryptedContet: content) {
                print("decrypt message: ", message)
                return message
            }
        }
        
        return "Error"
    }
    

}
