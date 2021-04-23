import Foundation
import UIKit
import Utility

final class AppSettingsPresenter {
    // MARK: Properties
    private (set) weak var parentController: AppSettingsController?
    
    // MARK: - Constructor
    init(parentController: AppSettingsController?) {
        self.parentController = parentController
    }
    
    func setupNavigationLeftItem() {
        if Device.IS_IPAD {
            _ = UIBarButtonItem(image: UIImage(), style: .done, target: self, action: nil)
            let leftNavigationItem = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"), style: .plain, target: self, action: #selector(menuButtonPressed))
            
            if UIDevice.current.orientation.isLandscape {
                parentController?.navigationItem.leftBarButtonItem = leftNavigationItem
            } else {
                parentController?.navigationItem.leftBarButtonItem = leftNavigationItem
            }
        } else {
            let leftNavigationItem = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"), style: .plain, target: self, action: #selector(menuButtonPressed))
            parentController?.navigationItem.leftBarButtonItem = leftNavigationItem
        }
        
        parentController?.navigationItem.title = Strings.Menu.settings.localized
        parentController?.navigationController?.updateTintColor()
    }
    
    @objc
    private func menuButtonPressed(_ sender: Any) {
        parentController?.router?.onTapMenu()
    }
}
