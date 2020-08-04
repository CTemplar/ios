import Foundation
import UIKit
import Networking
import Utility

enum WhiteBlackListsMode: Int {
    case whiteList   = 0
    case blackList   = 1
}

final class WhiteBlackListsViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var addContactButton: UIButton!
    
    // MARK: Properties
    var user = UserMyself()
    
    var listMode = WhiteBlackListsMode.whiteList
    
    var searchActive : Bool = false
    
    private (set) var presenter: WhiteBlackListsPresenter?
    
    private (set) var dataSource: WhiteBlackListsDataSource?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let configurator =  WhiteBlackListsConfigurator()
        configurator.configure(viewController: self)
        
        dataSource = WhiteBlackListsDataSource(parent: self, tableView: tableView)
        
        presenter?.setup()
        
        presenter?.updateAddButtonTitle(basedOnMode: listMode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)        
        presenter?.interactor?.getWhiteListContacts(silent: false)
        presenter?.interactor?.getBlackListContacts(silent: false)
    }
    
    // MARK: - Setup
    func setup(presenter: WhiteBlackListsPresenter?) {
        self.presenter = presenter
    }
    
    func setup(user: UserMyself) {
        self.user = user
    }

    // MARK: - Actions
    @IBAction func addContactButtonPressed(_ sender: AnyObject) {
        presenter?.addContactButtonPressed(listMode: self.listMode)
    }
}

// MARK: - Add White/Black list contact
extension WhiteBlackListsViewController {
    func addAction(name: String, email: String) {
        switch listMode {
        case WhiteBlackListsMode.whiteList:
            self.presenter?.interactor?.addContactToWhiteList(name: name, email: email)
        case WhiteBlackListsMode.blackList:
            self.presenter?.interactor?.addContactToBlackList(name: name, email: email)
        }
    }
}
