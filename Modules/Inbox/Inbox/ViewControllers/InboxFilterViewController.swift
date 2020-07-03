import UIKit
import Utility

class InboxFilterViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var filterTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var applyBarButtonItem: UIBarButtonItem!
    
    // MARK: Properties
    private lazy var dataSource: InboxFilterDatasource = {
       return InboxFilterDatasource(tableView: filterTableView)
    }()
    
    var onApplyFilters: (([InboxFilter]) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.topItem?.title = Strings.Inbox.filters.localized
        applyBarButtonItem.title = Strings.Button.applyButton.localized
        dataSource.reload()
    }

    // MARK: - Actions
    @IBAction func onTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapReset(_ sender: Any) {
        dataSource.removeFilters()
    }
    
    @IBAction func onTapApplyFilters(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            guard let safeSelf = self else {
                return
            }
            safeSelf.onApplyFilters?(safeSelf.dataSource.appliedFilters)
        }
    }
}
