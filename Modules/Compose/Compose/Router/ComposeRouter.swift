import Foundation
import UIKit
import Utility
import MobileCoreServices
import PhotosUI

final class ComposeRouter: NSObject, PHPickerViewControllerDelegate {
    // MARK: Properties
    private weak var parentViewController: ComposeController?
    private (set) var onCompletion: ((URL) -> Void)?
    
    // MARK: - Constructor
    init(parentViewController: ComposeController) {
        self.parentViewController = parentViewController
        super.init()
    }
    
    func showSetPasswordViewController(_ onCompletion: @escaping ((String, String, Int) -> Void)) {
        let setPasswordVC: SetPasswordViewController = UIStoryboard(storyboard: .setPassword,
                                                                    bundle: Bundle(for: SetPasswordViewController.self))
        .instantiateViewController()
        
        setPasswordVC.onCompletion = { (password, hint, hours) in
            onCompletion(password, hint, hours)
        }
        
        parentViewController?.present(setPasswordVC, animated: true, completion: nil)
    }
    
    func showSchedulerViewController(mode: SchedulerMode,
                                     existingDate: Date,
                                     onCompletion: @escaping ((SchedulerMode, Date) -> Void)) {
        let schedulerVC: SchedulerViewController = UIStoryboard(storyboard: .scheduler,
                                                                    bundle: Bundle(for: SchedulerViewController.self))
        .instantiateViewController()
        
        schedulerVC.mode = mode
        schedulerVC.scheduledDate = existingDate
        schedulerVC.onCompletion = onCompletion
        parentViewController?.present(schedulerVC, animated: true, completion: nil)
    }
    
    func showImagePickerWithCamera(_ onCompletion: ((URL) -> Void)?) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            self.onCompletion = onCompletion
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            parentViewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func showImagePickerWithLibrary(_ onCompletion: ((URL) -> Void)?) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
            //            self.onCompletion = onCompletion
            //            let imagePicker = UIImagePickerController()
            //            imagePicker.delegate = self
            //            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //            imagePicker.mediaTypes = [kUTTypeImage as String]
            //            imagePicker.allowsEditing = false
            //            parentViewController?.present(imagePicker, animated: true, completion: nil)
            
            
//            if #available(iOS 14, *) {
//                // using PHPickerViewController
//                self.onCompletion = onCompletion
//                var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
//                config.selectionLimit = 1
//                config.filter = .images
//                config.preferredAssetRepresentationMode = .current
//                let picker = PHPickerViewController(configuration: config)
//                picker.delegate = self
//                DispatchQueue.main.async {
//                    self.parentViewController?.present(picker, animated: true, completion: nil)
//                }
//            } else {
                self.onCompletion = onCompletion
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                parentViewController?.present(imagePicker, animated: true, completion: nil)
           // }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ComposeRouter: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        if let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            DPrint("imgUrl:", imageUrl)
            onCompletion?(imageUrl)
            parentViewController?.dismiss(animated: true, completion: nil)
        } else {
            guard let image = info[.originalImage] as? UIImage else { return }
            
            let date = Date()
            
            let dateString = UtilityManager.shared.formatterService.formatDateToStringDateWithTime(date: date)
            
            let imageName = "Created_with_camera_" + dateString + ".jpg"
            
            guard let path = FileManager.default.urls(for: .documentDirectory,
                                                      in: .userDomainMask).first else {
                fatalError("Path not found")
            }
            
            let imageUrl = path.appendingPathComponent(imageName)
            
            DispatchQueue.global().async {
                if let jpegData = image.jpegData(compressionQuality: 0.5) {
                    try? jpegData.write(to: imageUrl)
                }
                
                DispatchQueue.main.async {
                    DPrint("imgUrl:", imageUrl)
                    self.onCompletion?(imageUrl)
                    self.parentViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parentViewController?.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        guard !results.isEmpty else {
            parentViewController?.dismiss(animated: true, completion: nil)
            return
        }
        
        for result in results {
            let itemProvider = result.itemProvider
            
            guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
                  let utType = UTType(typeIdentifier)
            else { continue }
            
            if utType.description == "public.png" {
                self.getPhoto(from: itemProvider, isLivePhoto: false)
                parentViewController?.dismiss(animated: true, completion: nil)
                return
            }
        }
        parentViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    private func getPhoto(from itemProvider: NSItemProvider, isLivePhoto: Bool) {
        let objectType: NSItemProviderReading.Type = !isLivePhoto ? UIImage.self : PHLivePhoto.self
        
        if itemProvider.canLoadObject(ofClass: objectType) {
            itemProvider.loadObject(ofClass: objectType) { object, error in
                if let error = error {
                    print(error.localizedDescription)
                    //return
                }
                
                if !isLivePhoto {
                   // if let image = UIImage(named: "newtest")  {
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            let date = Date()
                            
                            let dateString = UtilityManager.shared.formatterService.formatDateToStringDateWithTime(date: date)
                            
                            let imageName = "Created_with_camera_" + dateString + ".jpg"
                            
                            guard let path = FileManager.default.urls(for: .documentDirectory,
                                                                      in: .userDomainMask).first else {
                                fatalError("Path not found")
                            }
                            
                            let imageUrl = path.appendingPathComponent(imageName)
                            
                            DispatchQueue.global().async {
                                if let jpegData = image.pngData() {
                                    try? jpegData.write(to: imageUrl)
                                }
                                
                                DispatchQueue.main.async {
                                    DPrint("imgUrl:", imageUrl)
                                    self.onCompletion?(imageUrl)
                                }
                            }
                        }
                    }
                } else {
                    if let livePhoto = object as? PHLivePhoto {
                        DispatchQueue.main.async {
                        }
                    }
                }
            }
        }
    }

}
