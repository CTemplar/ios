import Foundation
import UIKit
import Networking
import Utility

class ManageFoldersConfigurator {
    func configure(viewController: ManageFoldersViewController) {
        let router = ManageFoldersRouter(viewController: viewController)
        
        let interactor = ManageFoldersInteractor(viewController: viewController)

        let presenter = ManageFoldersPresenter(viewController: viewController, interactor: interactor)
        
        viewController.setup(router: router)
        viewController.setup(presenter: presenter)
    }
}
