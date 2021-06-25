//
//  FilterInteractor.swift
//  AppSettings
//


import Foundation
import UIKit
import Utility
import Networking

class FilterInteractor:NSObject {
    // MARK: Properties
    private let apiService = NetworkManager.shared.apiService
    private (set) weak var parentController: FilterVC?
    private var mailboxes: [Mailbox] = []
     weak var tableView: UITableView?
    
    // MARK: - Constructor
    init(parentController: FilterVC?) {
        self.parentController = parentController
       
    }
    
    
    // MARK: - API Calls
    func filterList(_ isFromEdit:Bool = false) {
        Loader.start()
        apiService.filterList(completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                if (isFromEdit == true) {
                    Loader.stop()
                }
                switch result {
                case .success(let value):
                    
                    if let filterList = value as? [Filter] {
                        self?.parentController?.presenter?.filterList(filter: filterList)
                    }
                case .failure(let error):
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        })
    }
    // MARK: - API Calls
    func deleteFilter(id:String) {
        Loader.start()
        apiService.deleteFilter(filterId: id, completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.parentController?.presenter?.refreshFilterAfterDelete()
                case .failure(let error):
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        })
    }
    // MARK: - API Folder list
    func getFolders() {
        apiService.customFoldersList(limit: 200, offset: 0) { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch(result) {
                case .success(let value):
                    if let folderList = value as? FolderList {
                        self?.parentController?.presenter?.update(folders: folderList.foldersList ?? [])
                    } else {
                        self?.parentController?.presenter?.update(folders: [])
                    }
                case .failure(let error):
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                    
                }
            }
        }
    }
}
