import UIKit
import Utility

class DashboardTableViewController: UITableViewController {

    // MARK: Properties
    private var dataSource: DashboardDataSource?
    private let identifier = "settingsDashboardTableViewCellIdentifier"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setupNavigationBar()
    }
    
    // MARK: - UI
    private func setupNavigationBar() {
        title = dataSource?.navigationTitle
    }
    
    // MARK: - Setup
    func setup(with dataSource: DashboardDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections() ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfRows(in: section) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        // Configure the cell...
        if let item = dataSource?.item(at: indexPath) {
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.value
        }
        
        cell.selectionStyle = .none
        return cell
    }

    // MARK: - Actions
    @objc
    private func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
