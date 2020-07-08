import Foundation
import Networking

class DashboardConfigurator {
    func configure(viewController: DashboardTableViewController,
                   user: UserMyself) {        
        let accountType: (String, String) = ("accountType".localized(), user.settings.planType ?? "notAvailable".localized())
        let userName: (String, String) = ("userName".localized(), user.username ?? "notAvailable".localized())
        
        let domainCount = user.settings.domainCount == nil ? "notAvailable".localized() : "\(user.settings.domainCount!)"
        let numberOfDomains: (String, String) = ("customDomainNumber".localized(), domainCount)

        let addressesCount = user.mailboxesList == nil ? "notAvailable".localized() : "\(user.mailboxesList!.count)"
        let numberOfAddresses: (String, String) = ("addressNumber".localized(), addressesCount)

        let dataSource = DashboardDataSource(with: [
            .navigationTitle("Dashboard".localized()),
            .accountType(accountType.0, accountType.1),
            .userName(userName.0, userName.1),
            .numberOfCustomDomains(numberOfDomains.0, numberOfDomains.1),
            .numebrOfAdressess(numberOfAddresses.0, numberOfAddresses.1)
            ]
        )
        viewController.setup(with: dataSource)
    }
}
