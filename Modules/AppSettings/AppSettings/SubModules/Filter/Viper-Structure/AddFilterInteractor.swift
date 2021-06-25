//
//  AddFilterInteractor.swift
//  AppSettings
//


import Foundation
import UIKit
import Utility
import Networking

class AddFilterInteractor:NSObject {
    // MARK: Properties
    private let apiService = NetworkManager.shared.apiService
    private (set) weak var parentController: AddFilterVC?
    private var mailboxes: [Mailbox] = []
     weak var tableView: UITableView?
    
    // MARK: - Constructor
    init(parentController: AddFilterVC?) {
        self.parentController = parentController
    }
    
    
    // MARK: - API Calls
    func filterList() {
        
    }
    
    func editFilter(filter: Filter) {
        Loader.start()
        apiService.editFilter(model: filter, completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch result {
                case .success(let value):
                    if let filter = value as? Filter {
                        self?.parentController?.presenter?.refreshFilter(filter: filter)
                    }
                case .failure(let error):
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        })
    }
    
    
    func addFilter(filter: Filter) {
        Loader.start()
        apiService.addFilter(model: filter, completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch result {
                case .success(let value):
                    if let filter = value as? Filter {
                        self?.parentController?.presenter?.updateFilter(filter: filter)
                    }
                case .failure(let error):
                    self?.parentController?.showAlert(with: Strings.AppError.error.localized,
                                                      message: error.localizedDescription,
                                                      buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        })
    }
}
