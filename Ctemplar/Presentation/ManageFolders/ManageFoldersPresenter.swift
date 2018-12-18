//
//  ManageFoldersPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class ManageFoldersPresenter {
    
    var viewController   : ManageFoldersViewController?
    var interactor       : ManageFoldersInteractor?
    
    func setDataSource(folders: Array<Folder>) {
    
        self.viewController!.dataSource?.foldersArray = folders
        self.viewController!.dataSource?.reloadData()
    
        self.setupTable(folders: folders)
    }

    func setupTable(folders: Array<Folder>) {
        
        if folders.count > 0 {
            self.viewController!.foldersTableView.isHidden = false
            self.viewController!.addFolderView.isHidden = false
        } else {
            self.viewController!.foldersTableView.isHidden = true
            self.viewController!.addFolderView.isHidden = true
        }
    }
    
    func setupBackButton() {
        
        let backButton = UIBarButtonItem(image: UIImage(named: k_darkBackArrowImageName), style: .done, target: self, action: #selector(backAction))
        
        self.viewController!.navigationController?.navigationBar.tintColor = k_contactsBarTintColor
        self.viewController!.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backAction() {
        self.viewController?.router?.backAction()
    }
    
    func showDeleteFolderAlert(folderID: Int) {
        
        let params = Parameters(
            title: "deleteFolderTitle".localized(),
            message: "deleteFolder".localized(),
            cancelButton: "cancelButton".localized(),
            otherButtons: ["deleteButton".localized()]
        )
        
        AlertHelperKit().showAlertWithHandler(self.viewController!, parameters: params) { buttonIndex in
            switch buttonIndex {
            case 0:
                print("Cancel Delete")
            default:
                print("Delete")
                self.interactor?.deleteFolder(folderID: folderID)
            }
        }
    }
}
