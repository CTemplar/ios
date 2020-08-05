import Foundation
import Networking
import Inbox

final class GlobalSearchConfigurator {
    func configure(withSearchController searchVC: GlobalSearchViewController,
                   user: UserMyself,
                   onTapMessage: @escaping ((EmailMessage, UserMyself, ViewInboxEmailDelegate?) -> Void)) {
        let interactor = GlobalSearchInteractor()
        let router = GlobalSearchRouter(searchController: searchVC, onTapMessage: onTapMessage)
        let presenter = GlobalSearchPresenter(searchController: searchVC, interactor: interactor, router: router)
        
        interactor.setup(presenter: presenter)
        
        searchVC.setup(user: user)
        searchVC.setup(presenter: presenter)
    }
}
