import UIKit
import Utility
import Networking
import Inbox

class GlobalSearchViewController: UIViewController, EmptyStateMachine {

    // MARK: IBOutlets
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var emptyStateStackView: UIStackView!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    // MARK: Properties
    private (set) var presenter: GlobalSearchPresenter?
    private (set) var dataSource: GlobalSearchDataSource?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // Get updated folders
        presenter?.getAllFolders()
        
        dataSource = GlobalSearchDataSource(tableView: searchTableView, presenter: self.presenter)
        dataSource?.updateDatasource(by: [])
        presenter?.setupUI()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.presenter?.tweakSearchController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter?.updateNavigationColors()
        
        if presenter?.isViewControllerAppearing == false {
            presenter?.tweakSearchController()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.isViewControllerAppearing = false
    }

    // MARK: - Setup
    func setup(presenter: GlobalSearchPresenter) {
        self.presenter = presenter
    }
    
    func setup(user: UserMyself) {
        dataSource?.update(user: user)
    }
}

extension GlobalSearchViewController: ViewInboxEmailDelegate {
    func didUpdateReadStatus(for message: EmailMessage, status: Bool) {
        dataSource?.updateMessageStatus(message: message, status: status)
        if let menu = SharedInboxState.shared.selectedMenu {
            NotificationCenter.default.post(name: .updateMessagesReadCountNotificationID,
                                            object:
                [
                    "name": menu.menuName,
                    "isRead": status
                ]
            )
        }
    }
}
