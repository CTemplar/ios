import UIKit
import Networking
import Utility

class EncryptionController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    private (set) var dataSource: EncryptionDatasource?
    private (set) var interactor: EncryptionInteractor?
    private (set) var user: UserMyself = UserMyself()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        interactor = EncryptionInteractor(parentController: self)
        dataSource = EncryptionDatasource(tableView: tableView, parentController: self)
        dataSource?.setup(user: user)
        dataSource?.setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarTitle()
        setupCloseButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dataSource?.adjustFooterViewHeightToFillTableView()
    }
    
    // MARK: - UI Setup
    func setNavigationBarTitle() {
        navigationController?.updateTintColor()
        title = Strings.AppSettings.security.localized
    }
    
    func setupCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
    }
    
    // MARK: - Actions
    @objc
    private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Setup
    func setup(user: UserMyself) {
        self.user = user
    }
}
