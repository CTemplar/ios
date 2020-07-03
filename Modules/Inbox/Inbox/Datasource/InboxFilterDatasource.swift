import Foundation
import UIKit

final class InboxFilterDatasource: NSObject {
    // MARK: Properties
    private let filters: [InboxFilter] = InboxFilter.allCases
    private (set) var appliedFilters: [InboxFilter]
    private var tableView: UITableView
    private let identifier = "InboxFilterCell"
    
    // MARK: - Constructor
    init(tableView: UITableView) {
        self.tableView = tableView
        self.appliedFilters = SharedInboxState.shared.appliedFilters
        super.init()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 60.0
    }
    
    // MARK: - Datasource Helper
    func reload() {
        tableView.reloadData()
    }
    
    func applyFilters() {
        SharedInboxState.shared.update(appliedFilters: appliedFilters)
    }
    
    func removeFilters() {
        appliedFilters.removeAll()
        SharedInboxState.shared.update(appliedFilters: appliedFilters)
        reload()
    }
}
// MARK: - UITableViewDelegate & UITableViewDatasource
extension InboxFilterDatasource: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = filters[indexPath.row].localized
        cell.accessoryType = appliedFilters.contains(filters[indexPath.row]) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let filter = filters[indexPath.row]
        
        if appliedFilters.contains(filter) {
            appliedFilters.removeAll(where: { $0 == filter })
        } else {
            appliedFilters.append(filter)
        }
        
        reload()
    }
}
