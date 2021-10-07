//
//  ComposerInteractor.swift
//  AppSettings
//


import Foundation
import UIKit
import Utility
import Networking

class ComposerInteractor: NSObject {
    private let apiService = NetworkManager.shared.apiService
    private (set) weak var parentController: ComposeVC?
//    private var mailboxes: [Mailbox] = []
     weak var tableView: UITableView?
    
    init(parentController: ComposeVC?) {
        self.parentController = parentController
       
    }
    
    
    func addComposer(composer: Composer, id: Int) {
        Loader.start()
        apiService.addComposer(model: composer, id: id, completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch result {
                case .success(let value):
                    if let settings = value as? Settings {
                        print("done composer save")
                        self?.parentController?.presenter?.updateData(settings: settings)
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
