import Foundation
import Utility

struct DashboardDataSource: Configurable {
    // MARK: Properties
    typealias AdditionalConfig = DashboardConfig
    enum DashboardConfig: Configuration {
        case navigationTitle(String)
        case accountType(String, String)
        case userName(String, String)
        case numberOfCustomDomains(String, String)
        case numebrOfAdressess(String, String)
    }

    var navigationTitle: String!
    private var rows: [DashboardConfig] = []
    
    // MARK: Initializer
    init(with configs: [DashboardConfig]) {
        for config in configs {
            switch config {
            case .navigationTitle(let title):
                navigationTitle = title
            case .accountType,
                 .userName,
                 .numberOfCustomDomains,
                 .numebrOfAdressess:
                rows.append(config)
            }
        }
    }
    
    // MARK: - Datasource
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRows(in section: Int) -> Int {
        return rows.count
    }
    
    func item(at indexPath: IndexPath) -> (title: String, value: String)? {
        if rows.count > indexPath.row {
            let row = rows[indexPath.row]
            switch row {
            case .accountType(let title, let value),
                 .userName(let title, let value),
                 .numberOfCustomDomains(let title, let value),
                 .numebrOfAdressess(let title, let value):
                return (title: title, value: value)
            case .navigationTitle: break
            }
        }
        return nil
    }
}
