import Foundation
import UIKit
import Networking

class MoveToViewController: UIViewController {
    
    // MARK: Properties
    private (set) var presenter: MoveToPresenter?
    
    private (set) var router: MoveToRouter?
    
    private (set) var dataSource: MoveToDataSource?
    
    var selectedMessagesIDArray: [Int] = []
    
    var delegate: MoveToViewControllerDelegate?
    
    var user = UserMyself()
    var allMailsSelected = false
    var lastAppliedActionMessage: EmailMessage?

    // MARK: IBOutlets
    @IBOutlet var applyButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var addFolderButton: UIButton!
    @IBOutlet var manageFolderButton: UIButton!
    @IBOutlet var manageFolderView: UIView!
    @IBOutlet var addFolderLabel: UILabel!
    @IBOutlet var selectFolderLabel: UILabel!
    @IBOutlet var manageFolderLabel: UILabel!
    @IBOutlet var addFolderImage: UIImageView!
    @IBOutlet var moveToTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let configurator = MoveToConfigurator()
        configurator.configure(viewController: self)
        
        dataSource = MoveToDataSource(parent: self, tableView: moveToTableView)
                
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(customFoldersUpdated(notification:)), name: .updateCustomFolderNotificationID, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .updateCustomFolderNotificationID, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.interactor?.customFoldersList()
    }
    
    // MARK: - Actions
    @IBAction func addButtonPressed(_ sender: Any) {
        self.router?.showAddFolderViewController()
    }
    
    @IBAction func manageFoldersButtonPressed(_ sender: Any) {
        self.router?.showFoldersManagerViewController()
    }
    
    @IBAction func applyButtonPressed(_ sender: Any) {
        self.presenter?.interactor?.applyButtonPressed()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Setup
    func setup(presenter: MoveToPresenter) {
        self.presenter = presenter
    }
    
    func setup(router: MoveToRouter) {
        self.router = router
    }
    
    // MARK: - Gesture Actions
    @objc
    private func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Observer Actions
    @objc
    private func customFoldersUpdated(notification: Notification) {
        let customFolders = notification.object as? [Folder] ?? []
        dataSource?.update(by: customFolders)
    }
}
