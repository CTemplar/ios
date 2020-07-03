import Foundation
import UIKit
import Networking

class ManageFoldersViewController: UIViewController {
    
    // MARK: Properties
    private (set) var presenter: ManageFoldersPresenter?
    
    private (set) var router: ManageFoldersRouter?
    
    private (set) var dataSource: ManageFoldersDataSource?

    var showFromSideMenu = true
    
    var showFromSettings = false
    
    var upgradeToPrimeView: UpgradeToPrimeView?
    
    private var folders: [Folder] = []
    
    private var user: UserMyself?
    
    @IBOutlet weak var foldersTableView: UITableView!
    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var emptyFolderStackView: UIStackView!
    @IBOutlet weak var emptyFolderLabel: UILabel!
    @IBOutlet weak var addFolderBarButtonItem: UIBarButtonItem!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let configurator = ManageFoldersConfigurator()
        configurator.configure(viewController: self)
        
        if !showFromSideMenu {
            presenter?.setupBackButton()
        }
        
        // Setup Datasource
        dataSource = ManageFoldersDataSource(parent: self,
                                             tableView: foldersTableView,
                                             folders: folders,
                                             user: user
        )
        
        dataSource?.onUpdateDataSource = { [weak self] (dataAvailable) in
            self?.presenter?.toggleEmptyState(showEmptyState: dataAvailable == false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fetch Folders
        presenter?.interactor?.foldersList(silent: false)
        
        if Device.IS_IPAD {
            if showFromSideMenu {
                presenter?.setupNavigationLeftItem()
            }
        }
    }
    
    // MARK: - Setup
    func setup(presenter: ManageFoldersPresenter) {
        self.presenter = presenter
    }
    
    func setup(router: ManageFoldersRouter) {
        self.router = router
    }

    func setup(folderList: [Folder]) {
        if dataSource != nil {
            dataSource?.update(folders: folderList)
        } else {
            folders = folderList
        }
    }
    
    func updateState() {
        presenter?.updateState()
    }
    
    func setup(user: UserMyself?) {
        if dataSource != nil {
            dataSource?.update(user: user)
        } else {
            self.user = user
        }
    }
    
    // MARK: - Actions
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        if showFromSideMenu {
            router?.showInboxSideMenu()
        } else {
            router?.backAction()
        }
    }
    
    @IBAction func addFolderButtonPressed(_ sender: AnyObject) {
        presenter?.addFolderButtonPressed()
    }
    
    // MARK: - Orientation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if Device.IS_IPAD {
            if showFromSideMenu {
                presenter?.setupNavigationLeftItem()
            }
        }
    }
}
