//
//  AttachmentCollectionViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class AttachmentCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var fileNameLabel         : UILabel!
    @IBOutlet weak var fileExtensionLabel    : UILabel!
    @IBOutlet weak var fileExtensionView     : UIView!
    
    func setupCellWithData(attachment: Attachment) {
        
        if let fileUrl = attachment.contentUrl {
            self.fileNameLabel.text = self.fileName(fileUrl: fileUrl)
            self.fileExtensionLabel.text = self.fileExtension(fileUrl: fileUrl)
        }
    }
    
    func fileName(fileUrl: String) -> String? {
        
        var fileName : String = ""
        
        fileName = URL(fileURLWithPath: fileUrl).lastPathComponent
        
        return fileName
    }
    
    func fileExtension(fileUrl: String) -> String? {
        
        var fileExtension : String = ""
        
        fileExtension = URL(fileURLWithPath: fileUrl).pathExtension
        
        return fileExtension.uppercased()
    }
}
