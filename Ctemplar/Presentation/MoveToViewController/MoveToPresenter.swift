//
//  MoveToPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 06.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit

class MoveToPresenter {
    
    var viewController   : MoveToViewController?
    var interactor       : MoveToInteractor?
    
    func applyButton(enabled: Bool) {
        
        if enabled {
            self.viewController?.applyButton.isEnabled = true
            self.viewController?.applyButton.alpha = 1.0
        } else {
            self.viewController?.applyButton.isEnabled = false
            self.viewController?.applyButton.alpha = 0.3
        }
    }
}
