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

    func setupTableView() {
  
        self.viewController!.dataSource?.foldersArray = self.viewController!.foldersList
        self.viewController!.dataSource?.reloadData()
        
        if self.viewController!.foldersList.count > 0 {
            self.viewController!.foldersTableView.isHidden = false
            self.viewController!.addFolderView.isHidden = false
        }
    }
}
