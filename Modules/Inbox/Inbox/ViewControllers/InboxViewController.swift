import UIKit
import SideMenu

class InboxViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noMessagePromptStackView: UIStackView!
    
    @IBOutlet weak var reloadButton: UIButton!
    
    @IBOutlet weak var messagesLabel: UILabel!
    
    @IBOutlet weak var unreadMessagesLabel: UILabel!
    
    @IBOutlet weak var generalToolbar: UIToolbar! {
        didSet {
            generalToolbar.isHidden = true
        }
    }
    
    @IBOutlet weak var draftToolbar: UIToolbar! {
        didSet {
            draftToolbar.isHidden = true
        }
    }
    
    @IBOutlet weak var selectionToolBar: UIToolbar! {
        didSet {
            selectionToolBar.isHidden = true
        }
    }
    
    @IBOutlet weak var undoToolBar: UIToolbar! {
        didSet {
            undoToolBar.isHidden = true
        }
    }
    
    @IBOutlet weak var inboxEmptyImageView: UIImageView!
    
    @IBOutlet weak var inboxEmptyLabel: UILabel!
    
    @IBOutlet weak var undoBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var composeButton: UIButton! {
        didSet {
            composeButton.layer.cornerRadius = composeButton.frame.size.height / 2
            composeButton.layer.masksToBounds = true
        }
    }
    
    // MARK: Properties
    private (set) var router: InboxRouter?
    private (set) var presenter: InboxPresenter?
    private (set) var dataSource: InboxDatasource?
    private (set) var selectedMenu = Menu.inbox
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
    }
    
    // MARK: - Setup
    func update(menu: Menu) {
        selectedMenu = menu
    }
    
    func setup(presenter: InboxPresenter) {
        self.presenter = presenter
    }
    
    func setup(router: InboxRouter) {
        self.router = router
    }
    
    func setup(dataSource: InboxDatasource) {
        self.dataSource = dataSource
    }
    
    // MARK: - UI
    func turnOnDraftToolBar() {
        selectionToolBar.isHidden = true
        undoToolBar.isHidden = true
        draftToolbar.isHidden = false
        toggleGeneralToolbar(shouldShow: false)
    }
    
    func turnOnSelectionToolBar() {
        selectionToolBar.isHidden = false
        draftToolbar.isHidden = true
        undoToolBar.isHidden = true
        toggleGeneralToolbar(shouldShow: false)
    }
    
    func turnOnUndoToolbar() {
        undoToolBar.isHidden = false
        draftToolbar.isHidden = true
        selectionToolBar.isHidden = true
        toggleGeneralToolbar(shouldShow: false)
    }
    
    func toggleGeneralToolbar(shouldShow: Bool) {
        generalToolbar.isHidden = shouldShow == false
        if shouldShow {
            selectionToolBar.isHidden = true
            draftToolbar.isHidden = true
            undoToolBar.isHidden = true
        }
    }
    
    // MARK: - Actions
    @objc
    private func onTapMenu(_ sender: Any) {
        router?.showSidemenu()
    }
    
    @IBAction func onTapFilter(_ sender: UIBarButtonItem) {
        presenter?.showFilterView(from: sender)
    }
    
    @IBAction func onTapMore(_ sender: UIBarButtonItem) {
        presenter?.showMoreActions()
    }
}

// MARK: - LeftBarButtonItemConfigurable
extension InboxViewController: LeftBarButtonItemConfigurable {
    func setupLeftBarButtonItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(onTapMenu(_:)
            )
        )
    }
}

// MARK: - UISearchResultsUpdating
extension InboxViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
