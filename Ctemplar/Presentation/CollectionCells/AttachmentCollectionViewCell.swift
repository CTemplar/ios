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
            self.setFileExtensionColor(ext: self.fileExtension(fileUrl: fileUrl)!)
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
    
    func setFileExtensionColor(ext: String) {
        
        var color : UIColor = k_otherColor
        
        if ext.count > 0 {
        
            switch ext.lowercased() {
            case DocumentsExtension.doc.rawValue:
                color = k_docColor
            case DocumentsExtension.pdf.rawValue:
                color = k_pdfColor
            case DocumentsExtension.png.rawValue:
                color = k_pngColor
            case DocumentsExtension.jpg.rawValue:
                color = k_jpgColor
            default:
                color = k_otherColor
            }
        }
        
        self.fileExtensionView.backgroundColor = color
    }
}
