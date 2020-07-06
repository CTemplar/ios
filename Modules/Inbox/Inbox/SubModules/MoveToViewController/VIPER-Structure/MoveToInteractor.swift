import Foundation
import Utility
import Networking

class MoveToInteractor {
    
    var viewController: MoveToViewController?
    var presenter: MoveToPresenter?
    var apiService: APIService?
    
    func customFoldersList() {
        Loader.start()
        apiService?.customFoldersList(limit: 200, offset: 0) { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch(result) {
                case .success(let value):
                    if let folderList = value as? FolderList {
                        self?.setCustomFoldersData(folderList: folderList)
                    }
                case .failure(let error):
                    print("error:", error)
                    self?.viewController?.showAlert(with: "Get Folders Error",
                                                    message: error.localizedDescription,
                                                    buttonTitle: Strings.Button.closeButton.localized
                    )
                }
            }
        }
    }
    
    func setCustomFoldersData(folderList: FolderList) {
        if let folders = folderList.foldersList {
            if !folders.isEmpty {
                viewController?.addFolderButton.isHidden = true
                viewController?.addFolderLabel.isHidden = true
                viewController?.addFolderImage.isHidden = true
                viewController?.manageFolderView.isHidden = false
            } else {
                viewController?.addFolderButton.isHidden = false
                viewController?.addFolderLabel.isHidden = false
                viewController?.addFolderImage.isHidden = false
                viewController?.manageFolderView.isHidden = true
            }
            viewController?.dataSource?.customFoldersArray = folders
            viewController?.dataSource?.reloadData()
        }
    }
    
    func moveMessagesListTo(selectedMessagesIdArray: Array<Int>, folder: String) {       
        var messagesIDList : String = ""
        
        for message in selectedMessagesIdArray {
            messagesIDList = messagesIDList + message.description + ","
        }
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex))
        
        apiService?.updateMessages(messageID: "",
                                   messagesIDIn: messagesIDList,
                                   folder: folder,
                                   starred: false,
                                   read: false,
                                   updateFolder: true,
                                   updateStarred: false,
                                   updateRead: false)
        { [weak self] (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(_):
                    DPrint("move list to another folder")
                    self?.postUpdateInboxNotification()
                    self?.viewController?.delegate?.didMoveMessage(to: folder)
                    self?.viewController?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    DPrint("error:", error)
                    self?.viewController?.showAlert(with: "Move Messages Error",
                                                    message: error.localizedDescription,
                                                    buttonTitle: Strings.Button.closeButton.localized
                    )
                }
            }
        }
    }
    
    func applyButtonPressed() {
        if self.viewController?.selectedMessagesIDArray.isEmpty == false {
            if self.viewController?.dataSource?.selectedFolderIndex != nil {
                let folderName = self.folderNameBy(selectedIndex: (self.viewController?.dataSource?.selectedFolderIndex)!)
                if folderName.count > 0 {
                    self.moveMessagesListTo(selectedMessagesIdArray: (self.viewController?.selectedMessagesIDArray)!, folder: folderName)
                }
            }
        }
    }
    
    func folderNameBy(selectedIndex: Int) -> String {
        var folderName = ""
        for (index, folder) in (self.viewController?.dataSource?.customFoldersArray)!.enumerated() {
            if index == selectedIndex {
                if let name = folder.folderName {
                    folderName = name
                }
            }
        }
        return folderName
    }
    
    func postUpdateInboxNotification() {
        NotificationCenter.default.post(name: .updateInboxMessagesNotificationID, object: true, userInfo: nil)
    }
}
