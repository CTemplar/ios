import Foundation
import Utility
import Networking

public final class InboxSideMenuPresenter {
    // MARK: Properties
    private (set) weak var viewController: InboxSideMenuController?
    public private (set) var interactor: InboxSideMenuInteractor?
    
    // MARK: - Setup
    func setup(viewController: InboxSideMenuController) {
        self.viewController = viewController
    }
    
    func setup(interactor: InboxSideMenuInteractor) {
        self.interactor = interactor
    }
    
    func setupUserProfileBar(mailboxes: Array<Mailbox>, userName: String) {
        let mailbox = NetworkManager.shared.apiService.defaultMailbox(mailboxes: mailboxes)
        viewController?.emailLabel.text = mailbox.email
        viewController?.nameLabel.text = userName
    }
    
    func logOut() {
        let params = AlertKitParams(
            title: Strings.Logout.logoutTitle.localized,
            message: Strings.Logout.logoutMessage.localized,
            cancelButton: Strings.Button.cancelButton.localized,
            otherButtons: [
                Strings.Button.logoutButton.localized
            ]
        )
        viewController?.showAlert(with: params, onCompletion: { [weak self] (index) in
            switch index {
            case 0:
                DPrint("Cancel Logout")
            default:
                DPrint("Logout")
                self?.interactor?.logOut()
            }
        })
    }
}
