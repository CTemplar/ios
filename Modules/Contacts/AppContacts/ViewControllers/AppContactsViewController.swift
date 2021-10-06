import UIKit
import Networking
import Combine
import Utility
import SwipeCellKit
import Inbox
import SnapKit

fileprivate extension AppContactsViewController {
    enum Section: String {
        case main = ""
    }
}

final class AppContactsDiffableDataSource: ContactsDataSource {
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return snapshot().sectionIdentifiers.map({ "\($0.first!)" }).compactMap({ $0 })
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return snapshot().indexOfSection(title)!
    }
}

final class AppContactsViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noContactImageView: UIImageView! {
        didSet {
            noContactImageView.isHidden = true
        }
    }
    @IBOutlet weak var noContactLabel: UILabel! {
        didSet {
            noContactLabel.isHidden = true
        }
    }
    
    // MARK: Properties
    private lazy var dataSource = makeDataSource()
    private var viewModel: AppContactsViewModel!
    private var anyCancellables = Set<AnyCancellable>()
    private lazy var defaultOptions: SwipeOptions = {
        return SwipeOptions()
    }()
    private (set) lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.delegate = self
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        return search
    }()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        return refreshControl
    }()
    
    private var trashButton: UIBarButtonItem?
    
    var onComposeEmail: ((String, UIViewController?) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.Menu.contacts.localized
        
        setupObserver()
        
        setupTableView()
        
        if viewModel.shouldShowSearchControl {
            setupSearchController()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Loader.start()
            self.viewModel.fetchContacts()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationItems()
    }
    
    deinit {
        anyCancellables.forEach({ $0.cancel() })
        anyCancellables.removeAll()
    }
    
    // MARK: - Setup
    private func setupObserver() {
        anyCancellables = [
            viewModel
                .$contacts
                .eraseToAnyPublisher()
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] in
                    self?.createSnapshot(from: $0)
                }),
            
            viewModel
                .errorMetadata
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (result) in
                    Loader.stop()
                    self?.showAlert(with: result.title,
                                    message: result.message,
                                    buttonTitle: Strings.Button.closeButton.localized)
                },
            
            viewModel
                .shouldEnableTrash
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] (shouldEnable) in
                    self?.trashButton?.isEnabled = shouldEnable
                })
            // ,
            
//            viewModel
//                .$searchText
//                .debounce(for: .milliseconds(800), scheduler: DispatchQueue.main) // debounces the string publisher, such that it delays the process of sending request to remote server.
//                .removeDuplicates()
//                .map({ (string) -> String? in
//                    return string
//                }) // prevents sending numerous requests and sends nil if the count of the characters is less than 1.
//                .compactMap{ $0 } // removes the nil values so the search string does not get passed down to the publisher chain
//                .sink { (_) in
//                    //
//                } receiveValue: { [weak self] (_) in
//                    self?.viewModel.updateDatasource()
//                }
        ]
    }
    
    
   
    private func setupTableView() {
         edgesForExtendedLayout = []
        tableView.backgroundColor = .tertiarySystemGroupedBackground
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.estimatedRowHeight = 100.0
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelection = true
        tableView.tintColor = AppStyle.Colors.loaderColor.color
        tableView.register(UINib(nibName: AppContactsCell.className,
                                  bundle: Bundle(for: AppContactsCell.self)),
                            forCellReuseIdentifier: AppContactsCell.className)
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.addSubview(self.refreshControl)
    }
    
    private func setupSearchController() {
        definesPresentationContext = true
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = Strings.Search.search.localized
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupNavigationItems() {
        navigationController?.prefersLargeTitle = true
        navigationItem.largeTitleDisplayMode = .automatic
        setupNavigationLeftItem()
        setupRightNavigationItems()
    }
    
    private func setupRightNavigationItems() {
        let addItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(createNewContact))
        navigationItem.setRightBarButton(addItem, animated: true)
    }
    
    private func setupNavigationLeftItem() {
        let barbuttonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"), style: .done, target: self, action: #selector(onTapMenu))
        navigationItem.setLeftBarButtonItems([barbuttonItem], animated: true)
    }
    
    // MARK: - Actions
    @objc
    private func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        viewModel.fetchContacts()
    }
    
    private func delete(contacts: [Contact]) {
        let params = AlertKitParams(
            title: Strings.Inbox.Alert.deleteTitle.localized,
            message: Strings.Inbox.Alert.deleteContact.localized,
            cancelButton: Strings.Button.cancelButton.localized,
            destructiveButtons: [Strings.Button.deleteButton.localized]
        )
        
        showAlert(with: params, onCompletion: { [weak self] (index) in
            switch index {
            case 0: DPrint("Cancel Delete")
            default:
                DPrint("Delete")
                self?.viewModel.delete(contacts: contacts)
            }
        })
    }
    
    @objc
    private func onTapMenu() {
        sideMenuController?.revealMenu()
    }

    @objc
    private func createNewContact() {
        showContactDetails(of: Contact(), with: .Add)
    }

    private func showContactDetails(of contact: Contact, with mode: AddAppContactsViewModel.Mode) {
        if let addContactVC = UIStoryboard(name: "AppContacts", bundle: Bundle(for: AppContactsViewController.self))
            .instantiateViewController(identifier: AddAppContactsViewController.className) as? AddAppContactsViewController {
            let viewModel = AddAppContactsViewModel(contact: contact, mode: mode, isContactEncrypted: self.viewModel.contactEncrypted)
            addContactVC.configure(with: viewModel)
            addContactVC.onContactUpdateSuccess = { [weak self] in
                DispatchQueue.main.async {
                    Loader.start()
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                 self?.viewModel.fetchContacts()
                }
            }
            navigationController?.pushViewController(addContactVC, animated: false)
        }
    }
}

// MARK: - Search Delegates
extension AppContactsViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.setFilteredList(searchText: searchController.searchBar.text ?? "")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.clearFilter()
        searchBar.resignFirstResponder()
    }
}

// MARK: - Diffable Datasource
extension AppContactsViewController: UITableViewDelegate {
    private func createSnapshot(from contacts: [Contact]) {
        var sections: [String] = []
        
        var snapshot = ContactsSnapshot()
        
        contacts.forEach({
            if let prefix = $0.contactName?.first {
                sections.append("\(prefix.uppercased())")
            }
        })
        
        sections = sections.removingDuplicates()
        
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(viewModel.filterContacts(byPrefix: section, contacts: contacts), toSection: section)
        }
        
        // Force the update on the main thread to silence a warning about tableview not being in the hierarchy!
        DispatchQueue.main.async {
            self.noContactLabel.isHidden = contacts.isEmpty == false
            self.noContactImageView.isHidden = contacts.isEmpty == false
            self.noContactLabel.text = self.searchController.isActive ? self.viewModel.noSearchResultsText : self.viewModel.noContactsText
            self.dataSource.apply(snapshot, animatingDifferences: false)
            
             
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func makeDataSource() -> AppContactsDiffableDataSource {
        return AppContactsDiffableDataSource(
            tableView: tableView,
            cellProvider: { [weak self] (tableView, indexPath, contact) in
                return self?.configureCell(with: contact, for: indexPath, and: tableView) ?? UITableViewCell()
            }
        )
    }
    
    func configureCell(with contact: Contact, for indexPath: IndexPath, and tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppContactsCell.className,
                                                       for: indexPath) as? AppContactsCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: contact, foundText: "")
        cell.delegate = self
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = dataSource.snapshot().sectionIdentifiers[section].first?.uppercased()
        
        let headerView = UIView(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 30.0))

        let label = UILabel()
        label.text = sectionHeader
        label.font = .withType(.Default(.Bold))
        label.textColor = .label
        label.backgroundColor = .clear
        headerView.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(16.0)
            make.centerY.equalToSuperview()
        }
        
        headerView.backgroundColor = tableView.backgroundColor
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let contact = dataSource.itemIdentifier(for: indexPath) {
            showContactDetails(of: contact, with: .Edit)
        }
    }
}

// MARK: - Bindable
extension AppContactsViewController: Bindable {
    typealias ModelType = AppContactsViewModel
    
    func configure(with model: AppContactsViewModel) {
        self.viewModel = model
    }
}

// MARK: - SwipeTableViewCellDelegate
extension AppContactsViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        switch orientation {
        case .left:
            return nil
        case .right:
            return rightSwipeAction(for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        options.transitionStyle = defaultOptions.transitionStyle
        options.buttonSpacing = 0
        options.backgroundColor = .clear
        return options
    }
}

// MARK: - Swipe Actions
private extension AppContactsViewController {
    func rightSwipeAction(for indexPath: IndexPath) -> [SwipeAction]? {
        guard let contact = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        var actions: [SwipeAction] = []
        
        let trashAction = SwipeAction(style: .destructive, title: nil) { [weak self] (action, indexPath) in
            self?.delete(contacts: [contact])
        }
        
        trashAction.hidesWhenSelected = true
        configure(action: trashAction, with: .trash)
        
        actions.append(trashAction)
        
        if let emailId = contact.email, !emailId.isEmpty {
            let newMailAction = SwipeAction(style: .default, title: nil) { [weak self] (action, indexPath) in
                self?.onComposeEmail?(emailId, self)
            }
              
            newMailAction.hidesWhenSelected = true
            configure(action: newMailAction, with: .newMail)
            
            actions.append(newMailAction)
        }
        
        if let phone = contact.phone, !phone.isEmpty {
            let phoneAction = SwipeAction(style: .default, title: nil) { (action, indexPath) in
                let phoneNumber: String = "tel://\(phone)"
                UIApplication.shared.open((URL(string: phoneNumber)!), options: [:], completionHandler: nil)
            }
              
            phoneAction.hidesWhenSelected = true
            configure(action: phoneAction, with: .phoneCall)
            
            actions.append(phoneAction)
        }

        return actions
    }
    
    private func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: .titleAndImage)
        action.image = descriptor.image(forStyle: .circular, displayMode: .titleAndImage)
        action.backgroundColor = .clear
        action.textColor = descriptor.color(forStyle: .circular)
        action.font = .withType(.ExtraSmall(.Bold))
        action.transitionDelegate = ScaleTransition.default
    }
}
