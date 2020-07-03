import Foundation
import UIKit
import Networking

final class MoveToConfigurator {
    func configure(viewController: MoveToViewController) {
        
        let router = MoveToRouter(viewController: viewController)
        
        let interactor = MoveToInteractor()

        let presenter = MoveToPresenter(viewController: viewController, interactor: interactor)
        
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = NetworkManager.shared.apiService
        
        viewController.setup(presenter: presenter)
        viewController.setup(router: router)
    }
}
