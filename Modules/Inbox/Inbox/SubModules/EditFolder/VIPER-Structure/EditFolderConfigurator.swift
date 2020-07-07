import Foundation
import UIKit
import Utility
import Networking

final class EditFolderConfigurator {
    func configure(viewController: EditFolderViewController) {
        let interactor = EditFolderInteractor(viewController: viewController)        
        viewController.setup(interactor: interactor)
    }
}
