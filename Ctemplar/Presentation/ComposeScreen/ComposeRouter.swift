//
//  ComposeRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class ComposeRouter: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var viewController: ComposeViewController?
    
    func showSetPasswordViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SetPasswordStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_SetPasswordViewControllerID) as! SetPasswordViewController
        vc.delegate = self.viewController
        self.viewController?.present(vc, animated: true, completion: nil)
    }
    
    func showImagePickerWithCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            viewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func showImagePickerWithLibrary() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            viewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK: - pickerController delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            
            self.viewController?.presenter?.getPickedImage(imageUrl: imageUrl)
            
            print("imgUrl:", imageUrl)
        }
        
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        viewController?.dismiss(animated: true, completion: nil)
    }
}
