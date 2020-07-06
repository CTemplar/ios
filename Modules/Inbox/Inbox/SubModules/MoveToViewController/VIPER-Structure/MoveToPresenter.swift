import Foundation
import UIKit
import Utility

final class MoveToPresenter {
    // MARK: Properties
    private weak var viewController: MoveToViewController?
    private (set) var interactor: MoveToInteractor?
    
    // MARK: - Constructor
    init(viewController: MoveToViewController, interactor: MoveToInteractor) {
        self.viewController = viewController
        self.interactor = interactor
        
        setupUI()
    }
    
    // MARK: - UI
    func setupUI() {
        viewController?.title = Strings.Inbox.moveTo.localized
        viewController?.selectFolderLabel.text = Strings.ManageFolder.selectfolder.localized
        viewController?.addFolderLabel.text = Strings.ManageFolder.addFolder.localized
        viewController?.manageFolderLabel.text = Strings.Menu.manageFolders.localized
        viewController?.applyButton.title = Strings.Button.applyButton.localized
        viewController?.cancelButton.title = Strings.Button.cancelButton.localized
        
        applyButton(enabled: false)
    }
    
    // MARK: - Actions
    func applyButton(enabled: Bool) {
        viewController?.applyButton.isEnabled = enabled
    }
}
