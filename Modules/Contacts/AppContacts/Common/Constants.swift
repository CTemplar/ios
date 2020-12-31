import Networking
import UIKit
import Utility

typealias ContactsDataSource = ContactDefaultDataSource<String, Contact>
typealias ContactsSnapshot = NSDiffableDataSourceSnapshot<String, Contact>
typealias ContactDefaultDataSource = UITableViewDiffableDataSource
typealias ContactResponse = ((APIResult<(contacts: [Contact], didfetchAll: Bool)>) -> Void)
typealias ContactUpdateResponse = ((APIResult<Any>) -> Void)
let contactPageLimit = 20
