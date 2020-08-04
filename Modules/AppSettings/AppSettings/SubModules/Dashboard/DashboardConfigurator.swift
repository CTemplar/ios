import Foundation
import Networking
import Utility

class DashboardConfigurator {
    func configure(viewController: DashboardTableViewController,
                   user: UserMyself) {        
        let accountType: (String, String) = (Strings.Dashboard.accountType.localized,
                                             user.settings.planType ?? Strings.Dashboard.notAvailable.localized)
        let userName: (String, String) = (Strings.Dashboard.userName.localized,
                                          user.username ?? Strings.Dashboard.notAvailable.localized)
        
        let domainCount = user.settings.domainCount == nil ? Strings.Dashboard.notAvailable.localized : "\(user.settings.domainCount!)"
        let numberOfDomains: (String, String) = (Strings.Dashboard.customDomainNumber.localized, domainCount)

        let addressesCount = user.mailboxesList == nil ? Strings.Dashboard.notAvailable.localized : "\(user.mailboxesList!.count)"
        let numberOfAddresses: (String, String) = (Strings.Dashboard.addressNumber.localized, addressesCount)

        let dataSource = DashboardDataSource(with: [
            .navigationTitle(Strings.AppSettings.dashboard.localized),
            .accountType(accountType.0, accountType.1),
            .userName(userName.0, userName.1),
            .numberOfCustomDomains(numberOfDomains.0, numberOfDomains.1),
            .numebrOfAdressess(numberOfAddresses.0, numberOfAddresses.1)
            ]
        )
        viewController.setup(with: dataSource)
    }
}
