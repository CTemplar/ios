//
//  InboxFilterView.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 31.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

protocol InboxFilterDelegate {
    func applyAction(_ sender: AnyObject, appliedFilters: Array<Bool>)
}

class InboxFilterView: UIView {
    
    var delegate    : InboxFilterDelegate?
    
    @IBOutlet var closeButton           : UIButton!
    @IBOutlet var clearAllButton        : UIButton!
    
    @IBOutlet var starredFilterButton   : UIButton!
    @IBOutlet var unreadFilterButton    : UIButton!
    @IBOutlet var withAttachmentButton  : UIButton!
    
    @IBOutlet var cancelButton          : UIButton!
    @IBOutlet var applyButton           : UIButton!
    
    @IBOutlet var starredFilterCheckImage    : UIImageView!
    @IBOutlet var unreadFilterCheckImage     : UIImageView!
    @IBOutlet var withAttachmentCheckImage   : UIImageView!

    var parentFilters    : Array<Bool> = []
    var appliedFilters   : Array<Bool> = []
    
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
    
    func setup(appliedFilters: Array<Bool>) {
        
        self.parentFilters = appliedFilters
        
        self.setupLocal(appliedFilters: appliedFilters)
    }
    
    func setupLocal(appliedFilters: Array<Bool>) {
        
        self.appliedFilters = appliedFilters
        
        for (index, imageViewTag) in InboxFilterImagesTag.allCases.enumerated() {
            
            let filterApplied = self.appliedFilters[index]
            
            if let filterImageCheck = self.viewWithTag(imageViewTag.rawValue) as? UIImageView {
                filterImageCheck.isHidden = !filterApplied
            }
        }
    }
    
    func localApplyFilter(_ sender: AnyObject) {
        
        if sender.tag == InboxFilterViewButtonsTag.clearAllButton.rawValue {
            
            self.appliedFilters = [false, false, false]
            self.setupLocal(appliedFilters: self.appliedFilters)
            return
        }
        
        for (index, buttonTag) in InboxFilterButtonsTag.allCases.enumerated() {
            
            if sender.tag == buttonTag.rawValue {
                
                let filterApplied = self.appliedFilters[index]
                self.appliedFilters[index] = !filterApplied
                self.setupLocal(appliedFilters: self.appliedFilters)
            }
        }    
    }
    
    //MARK: - IBActions
    
    @IBAction func filterTappedAction(_ sender: AnyObject) {
        self.localApplyFilter(sender)
    }
    
    @IBAction func clearFilterTappedAction(_ sender: AnyObject) {
        self.localApplyFilter(sender)
    }
    
    @IBAction func applyButtonPressed(_ sender: AnyObject) {    
        delegate?.applyAction(sender, appliedFilters: self.appliedFilters)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {        
        delegate?.applyAction(sender, appliedFilters: self.parentFilters)
    }
}
