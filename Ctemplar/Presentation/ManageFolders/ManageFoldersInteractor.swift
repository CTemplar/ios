//
//  ManageFoldersInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import Networking

class ManageFoldersInteractor {
    
    var viewController  : ManageFoldersViewController?
    var presenter       : ManageFoldersPresenter?
    var apiService      : APIService?
    
    func foldersList(silent: Bool) {
        
        if !silent {
            Loader.start()
        }
        
        apiService?.customFoldersList(limit: 200, offset: 0) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let folderList = value as! FolderList                
                self.setFoldersData(folderList: folderList)
                
            case .failure(let error):
                print("error:", error)
                self.viewController?.showAlert(with: "Get Folders Error",
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
            }
            
            Loader.stop()
        }
    }
    
    func setFoldersData(folderList: FolderList) {
        
        if let folders = folderList.foldersList {

            self.presenter?.setDataSource(folders: folders)
            //self.presenter?.setupAddFolderButton()
        }
    }
    
    func deleteFolder(folderID: Int) {
        
        apiService?.deleteCustomFolder(folderID: folderID.description) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("value:", value)
                self.foldersList(silent: false)
                
            case .failure(let error):
                print("error:", error)
                self.viewController?.showAlert(with: "Delete Folder Error",
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
            }
        }
    }
}
