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
            self.viewController!.redBottomView.isHidden = true
        } else {
            self.viewController!.foldersTableView.isHidden = true
            self.viewController!.addFolderView.isHidden = true
            self.viewController!.redBottomView.isHidden = false
        }
    }
    
    func setupBackButton() {
        
        let backButton = UIBarButtonItem(image: UIImage(named: k_darkBackArrowImageName), style: .done, target: self, action: #selector(backAction))
        
        self.viewController!.navigationController?.navigationBar.tintColor = k_contactsBarTintColor
        self.viewController!.navigationItem.leftBarButtonItem = backButton
    }
    
    func setupAddFolderButtonLabel() {
        
        let labelText = self.viewController?.addFolderLabel.text?.localized()
        
        let textWidth = labelText?.widthOfString(usingFont: (self.viewController?.addFolderLabel.font)!)
        
        let viewWidth = k_plusImageWidth + k_addButtonLeftOffet + textWidth! + 3.0 //sometimes width calculation is small
        
        self.viewController?.addFolderViewWithConstraint.constant = viewWidth        
    }
    
    @objc func backAction() {
        self.viewController?.router?.backAction()
    }
    
    func addFolderButtonPressed() {
        
        if (self.viewController?.dataSource?.foldersArray.count)! > k_customFoldersLimitForNonPremium - 1 {
            if (self.viewController?.user.isPrime)! {
                self.viewController?.router?.showAddFolderViewController()
            } else {
                self.showAddFolderLimitAlert()
            }
        } else {
            self.viewController?.router?.showAddFolderViewController()
        }
    }
    
    func setupAddFolderButton() {
        
        if (self.viewController?.dataSource?.foldersArray.count)! > k_customFoldersLimitForNonPremium - 1 {            
            if (self.viewController?.user.isPrime)! {
                self.setAddFolderButton(enable: true)
            } else {
                self.setAddFolderButton(enable: false)
            }
        } else {
            self.setAddFolderButton(enable: true)
        }
    }
    
    func setAddFolderButton(enable: Bool) {
        
        if enable {
            self.viewController?.addFolderButton.isEnabled = true
            self.viewController?.addFolderButton.alpha = 1.0
        } else {
            self.viewController?.addFolderButton.isEnabled = false
            self.viewController?.addFolderButton.alpha = 0.6
        }
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
    /*
    func showAddFolderLimitAlert() {
        
        let params = Parameters(
            title: "infoTitle".localized(),
            message: "addFolderLimit".localized(),
            cancelButton: "closeButton".localized()
        )
        
        AlertHelperKit().showAlertWithHandler(self.viewController!, parameters: params) { buttonIndex in
            switch buttonIndex {
            case 0:
                print("Close")
            default:
                print("Other")
            }
        }
    }*/
    
    func showAddFolderLimitAlert() {
        
        self.viewController?.upgradeToPrimeView?.isHidden = !(self.viewController?.upgradeToPrimeView?.isHidden)!
    }
    
    func initAddFolderLimitView() {
        
        self.viewController?.upgradeToPrimeView = Bundle.main.loadNibNamed(k_UpgradeToPrimeViewXibName, owner: nil, options: nil)?.first as? UpgradeToPrimeView
        self.viewController?.upgradeToPrimeView?.frame = CGRect(x: 0.0, y: 0.0, width: self.viewController!.view.frame.width, height: self.viewController!.view.frame.height)
        //self.viewController?.upgradeToPrimeView?.delegate = self.viewController
        
        self.viewController?.navigationController!.view.addSubview((self.viewController?.upgradeToPrimeView)!)
        
        self.viewController?.upgradeToPrimeView?.isHidden = true
    }
}
