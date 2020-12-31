import Foundation
import UIKit
import Utility
import Networking

class InboxSideMenuConfigurator {
    // MARK: - Configuration
    func configure(viewController: InboxSideMenuController,
                   onTapContacts: (([Contact], UserMyself) -> Void)?,
                   onTapSettings: ((UserMyself) -> Void)?,
                   onTapManageFolders: (([Folder], UserMyself) -> Void)?,
                   onTapFAQ: (() -> Void)?) {
        
        let router = InboxSideMenuRouter(viewController: viewController,
                                         onTapContacts: onTapContacts,
                                         onTapSettings: onTapSettings,
                                         onTapManageFolders: onTapManageFolders,
                                         onTapFAQ: onTapFAQ
        )
                
        let presenter = InboxSideMenuPresenter()
        presenter.setup(viewController: viewController)
        
        let interactor = InboxSideMenuInteractor()
        interactor.setup(viewController: viewController)
        interactor.setup(presenter: presenter)
        
        presenter.setup(interactor: interactor)
        
        viewController.setup(presenter: presenter)
        viewController.setup(router: router)
        
        let dataSource = InboxSideMenuDataSource(with: [.menus(Menu.allMenu),
                                                        .preferences(Menu.Preferences.allCases),
                                                        .customFolders([])
        ])

        viewController.setup(dataSource: dataSource)
    }
}
