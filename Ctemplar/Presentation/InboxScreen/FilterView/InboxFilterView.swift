//
//  InboxFilterView.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 25.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

protocol InboxFilterDelegate {
    //func showNextQuizOverviewCard(_ sender: AnyObject)
}

class InboxFilterView: UIView {
    
    var delegate    : InboxFilterDelegate?    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
    }
}
