import Foundation
import UIKit

class WhiteBlackListsConfigurator {
    func configure(viewController : WhiteBlackListsViewController) {
        
        let interactor = WhiteBlackListsInteractor(viewController: viewController)

        let presenter = WhiteBlackListsPresenter(viewController: viewController, interactor: interactor)
        
        interactor.setup(presenter: presenter)
        
        viewController.setup(presenter: presenter)
    }
}
