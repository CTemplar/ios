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
    
    func showSchedulerViewController(mode: SchedulerMode) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SchedulerStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_SchedulerViewControllerID) as! SchedulerViewController
        vc.delegate = self.viewController
        vc.mode = mode
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
        
        print("info:", info)
        
        if let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            
            self.viewController?.presenter?.getPickedImage(imageUrl: imageUrl)
            
            print("imgUrl:", imageUrl)
        } else {
            
            guard let image = info[.originalImage] as? UIImage else { return }
            
            let date = Date()
            let dateString = self.viewController?.presenter?.formatterService?.formatDateToStringDateWithTime(date: date)
            
            let imageName = "Created_with_camera_" + dateString! + ".jpg"
            
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let imageUrl = path.appendingPathComponent(imageName)
            
            if let jpegData = image.jpegData(compressionQuality: 0.5) {
                try? jpegData.write(to: imageUrl)
            }

            print("imageUrl:", imageUrl)
            self.viewController?.presenter?.getPickedImage(imageUrl: imageUrl)
        }
        
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        viewController?.dismiss(animated: true, completion: nil)
    }
}
