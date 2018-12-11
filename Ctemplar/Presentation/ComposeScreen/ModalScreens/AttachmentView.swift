//
//  AttachmentView.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

protocol AttachmentDelegate {
    func deleteAttach(tag: Int)
}

class AttachmentView: UIView {
    
    var delegate    : AttachmentDelegate?
    
    @IBOutlet var progressViewWidthConstraint           : NSLayoutConstraint!
    
    @IBOutlet var titleLabel      : UILabel!
    @IBOutlet var deleteButton    : UIButton!
    
    @IBOutlet var backgroundProgressView    : UIView!
    @IBOutlet var progressView    : UIView!

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
    
    
    //MARK: - IBActions
    
    @IBAction func deleteAction(_ sender: AnyObject) {
       
        delegate?.deleteAttach(tag: self.tag)
    }
}
