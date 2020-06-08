import UIKit

class DashboardTableViewController: UITableViewController {

    // MARK: Properties
    private var dataSource: DashboardDataSource?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setupNavigationBar()
    }
    
    // MARK: - UI
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: k_navBar_titleColor]
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = k_navBar_titleColor
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
        let cell = tableView.dequeueReusableCell(withIdentifier: k_SettingsDashboardTableViewCellIdentifier, for: indexPath)

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
