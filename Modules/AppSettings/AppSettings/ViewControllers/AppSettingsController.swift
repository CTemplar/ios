import UIKit
import Utility
import Networking

class AppSettingsController: UIViewController, LeftBarButtonItemConfigurable, EmptyStateMachine {

    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    private (set) var datasource: AppSettingsDatasource?
    private (set) var router: AppSettingsRouter?
    private (set) var presenter: AppSettingsPresenter?
    private (set) var user = UserMyself()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.datasource = AppSettingsDatasource(tableView: tableView, parentViewController: self)
        self.datasource?.setup(user: user)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        setupLeftBarButtonItems()
    }
    
    // MARK: - Setup
    func setupNavigationBar() {
        title = Strings.Menu.settings.localized
    }
    
    func setupLeftBarButtonItems() {
        navigationController?.prefersLargeTitle = true
        navigationItem.largeTitleDisplayMode = .automatic
        presenter?.setupNavigationLeftItem()
    }
    
    func setup(router: AppSettingsRouter?) {
        self.router = router
    }
    
    func setup(user: UserMyself) {
        self.user = user
    }
    
    func setup(presenter: AppSettingsPresenter) {
        self.presenter = presenter
    }
}
