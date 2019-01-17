//
//  ManageFoldersInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class ManageFoldersInteractor {
    
    var viewController  : ManageFoldersViewController?
    var presenter       : ManageFoldersPresenter?
    var apiService      : APIService?
    
    func foldersList() {
        
        HUD.show(.progress)
        
        apiService?.customFoldersList(limit: 200, offset: 0) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let folderList = value as! FolderList                
                self.setFoldersData(folderList: folderList)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Get Folders Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
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
                self.foldersList()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Delete Folder Error", message: error.localizedDescription, button: "closeButton".localized())
            }           
        }
    }
}
