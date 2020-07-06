import Foundation
import UIKit

final class AddFolderConfigurator {
    func configure(viewController: AddFolderViewController) {
        let interactor = AddFolderInteractor(viewController: viewController)
        viewController.setup(interactor: interactor)
    }
}
