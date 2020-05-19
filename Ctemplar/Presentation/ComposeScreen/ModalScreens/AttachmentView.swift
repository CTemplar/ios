//
//  AttachmentView.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var fileUrl : URL!

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
    
    func setup(fileUrl: URL) {
        
        self.fileUrl = fileUrl
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        DispatchQueue.global(qos: .userInteractive).async {
            let fileData = try? Data(contentsOf: fileUrl)
            let fileSize = fileData?.sizeData() ?? ""
            let fileName = fileUrl.lastPathComponent
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.formatFileTitle(fileName: fileName, fileSize: fileSize)
            }
        }
    }
    
    func formatFileTitle(fileName: String, fileSize: String) {
        
        let sizeText = "(" + fileSize + ")"
        let titleText = fileName + " " + sizeText
        
        let attributedString = NSMutableAttributedString(string: titleText, attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 14.0)!,
            .foregroundColor: k_fileNameColor,
            .kern: 0.0
            ])
   
        _ = attributedString.setForgroundColor(textToFind: sizeText, color: k_otherColor)
        _ = attributedString.setFont(textToFind: sizeText, font: UIFont(name: k_latoBoldFontName, size: 14.0)!)
        
        titleLabel.attributedText = attributedString
    }
    
    //MARK: - IBActions
    
    @IBAction func deleteAction(_ sender: AnyObject) {
       
        delegate?.deleteAttach(tag: self.tag)
    }
}
