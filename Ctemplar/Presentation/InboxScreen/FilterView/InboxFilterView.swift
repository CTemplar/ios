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
    func applyAction(_ sender: AnyObject)
}

class InboxFilterView: UIView {
    
    var delegate    : InboxFilterDelegate?
    
    @IBOutlet var freeSpaceView     : UIView!
    @IBOutlet var barSpaceView     : UIView!
    
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
    
    //MARK: - IBActions
    
    @IBAction func tappedAction(_ sender: AnyObject) {
        delegate?.applyAction(sender)
    }
}
