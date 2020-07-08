import Foundation
import UIKit
import Utility
import Networking
import SideMenu

final class InboxSideMenuDataSource: NSObject, Configurable {
    
    enum InboxSideMenuDataSourceConfig: Configuration {
        case menus([Menu])
        case preferences([Menu.Preferences])
        case customFolders([Folder])
    }
    
    // MARK: Properties
    typealias AdditionalConfig = InboxSideMenuDataSourceConfig
    private var menus: [Menu] = []
    private var preferences: [Menu.Preferences] = []
    private (set) var customFolders: [Folder] = []
    private (set) var unreadMessages: [UnreadMessagesCounter] = []
    private (set) weak var tableView: UITableView?
    private (set) weak var parentController: InboxSideMenuController?
    private let formatterService = UtilityManager.shared.formatterService
    var showAllFolders = false
    
    // MARK: - Constructor
    init(with configs: [InboxSideMenuDataSourceConfig]) {
        super.init()
        configs.forEach { (config) in
            switch config {
            case .menus(let menus):
                self.menus = menus
            case .preferences(let preferences):
                self.preferences = preferences
            case .customFolders(let folders):
                self.customFolders = folders
            }
        }
    }
    
    // MARK: - Setup
    func setup(tableView: UITableView) {
        self.tableView = tableView
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        registerTableViewCell()
    }
    
    func setup(parent: InboxSideMenuController?) {
        self.parentController = parent
    }
    
    func update(customFolders: [Folder]) {
        self.customFolders = customFolders
    }
    
    func update(unreadMessages: [UnreadMessagesCounter]) {
        self.unreadMessages = unreadMessages
    }
    
    private func registerTableViewCell() {
        tableView?.register(UINib(nibName: SideMenuTableViewCell.className, bundle: Bundle(for: type(of: self))),
                            forCellReuseIdentifier: SideMenuTableViewCell.className)
        
        tableView?.register(UINib(nibName: SideMenuTableManageFolderCell.className, bundle: Bundle(for: type(of: self))),
                            forCellReuseIdentifier: SideMenuTableManageFolderCell.className)
        
        tableView?.register(UINib(nibName: CustomFolderTableViewCell.className, bundle: Bundle(for: type(of: self))),
                            forCellReuseIdentifier: CustomFolderTableViewCell.className)
    }
    
    // MARK: - Helpers
    func reload() {
        tableView?.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension InboxSideMenuDataSource: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Menu.SideMenuSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Menu.SideMenuSection(rawValue: section) else {
            return 0
        }
        
        switch sectionType {
        case .menu:
            return menus.count
        case .preferences:
            return preferences.count
        case .manageFolders:
            return 1
        case .customFolders:
            if showAllFolders {
                return customFolders.count + 1
            } else {
                if customFolders.count > Menu.customFoldersCount {
                    return Menu.customFoldersCount + 1
                } else {
                    return customFolders.count
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let separatorLineHeaderView: UIView =  UIView()
        separatorLineHeaderView.backgroundColor = k_sideMenuSeparatorColor
        return separatorLineHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Menu.SideMenuSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sectionType {
        case .menu:
            return configureMenuCell(ForRowAt: indexPath)
        case .preferences:
            return configurePreferencesCell(ForRowAt: indexPath)
        case .manageFolders:
            return configureManageFolderCell(ForRowAt: indexPath)
        case .customFolders:
            return configureCustomFolderCell(ForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sectionType = Menu.SideMenuSection(rawValue: indexPath.section) else {
            return
        }
        
        switch sectionType {
        case .menu,
             .manageFolders:
            let menu = sectionType == .menu ? menus[indexPath.row] : .manageFolders
            didSelect(menu: menu)
        case .preferences:
            let preferencesMenu = preferences[indexPath.row]
            didSelect(preferences: preferencesMenu)
        case .customFolders:
            didSelectCustomFolder(at: indexPath)
        }
    }
    
    // MARK: Cell Configurations
    private func configureMenuCell(ForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(withIdentifier: SideMenuTableViewCell.className,
                                                        for: indexPath) as? SideMenuTableViewCell else {
                                                            return UITableViewCell()
        }
        let menu = menus[indexPath.row]
        let selected = SharedInboxState.shared.selectedMenu?.menuName == menu.menuName
        let icon = menu.image
        let unreadCount = parentController?.presenter?.interactor?.getUnreadMessagesCount(with: unreadMessages,
                                                                                          folder: menu.rawValue,
                                                                                          apiFolderName: menu.rawValue) ?? 0
        cell.setupCell(selected: selected, icon: icon, title: menu.localized, unreadCount: unreadCount)
        return cell
    }
    
    private func configurePreferencesCell(ForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(withIdentifier: SideMenuTableViewCell.className) as? SideMenuTableViewCell else {
            return UITableViewCell()
        }
        let preferencesMenu = preferences[indexPath.row]
        let selected = SharedInboxState.shared.selectedPreferences == preferencesMenu
        let icon = preferencesMenu.image
        let unreadCount = parentController?.presenter?.interactor?.getUnreadMessagesCount(with: unreadMessages,
                                                                                          folder: preferencesMenu.rawValue,
                                                                                          apiFolderName: preferencesMenu.rawValue) ?? 0
        cell.setupCell(selected: selected, icon: icon, title: preferencesMenu.localized, unreadCount: unreadCount)
        return cell
    }
    
    private func configureManageFolderCell(ForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(withIdentifier: SideMenuTableManageFolderCell.className) as? SideMenuTableManageFolderCell else {
            return UITableViewCell()
        }
        
        let menu = Menu.manageFolders
        let selected = SharedInboxState.shared.selectedMenu?.menuName == Menu.manageFolders.menuName
        
        cell.setupCell(selected: selected, icon: menu.image, title: menu.localized, foldersCount: customFolders.count)
        return cell
    }
    
    private func configureCustomFolderCell(ForRowAt indexPath: IndexPath) -> UITableViewCell {
        func customFolderCell() -> UITableViewCell {
            guard let cell = tableView?.dequeueReusableCell(withIdentifier: CustomFolderTableViewCell.className) as? CustomFolderTableViewCell else {
                return UITableViewCell()
            }
            let folder = customFolders[indexPath.row]
            let folderName = folder.folderName ?? ""
            let selected = SharedInboxState.shared.selectedCustomFolderIndexPath == indexPath
            let folderColor = folder.color ?? ""
            let unreadCount = parentController?.presenter?.interactor?.getUnreadMessagesCount(with: unreadMessages,
                                                                                              folder: folderName,
                                                                                              apiFolderName: folderName) ?? 0
            cell.setupCustomFolderTableCell(selected: selected, iconColor: folderColor, title: folderName, unreadCount: unreadCount)
            return cell
        }
        
        func defaultFolderCell() -> UITableViewCell {
            guard let cell = tableView?.dequeueReusableCell(withIdentifier: defaultSideMenuCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.contentView.backgroundColor = k_readMessageColor
            return cell
        }
        
        if showAllFolders {
            if customFolders.count > indexPath.row {
                return customFolderCell()
            } else {
                if indexPath.row == customFolders.count {
                    let cell = defaultFolderCell()
                    cell.textLabel?.textColor = k_mailboxTextColor
                    cell.textLabel?.text = Strings.Menu.hideFolders.localized
                    return cell
                } else {
                    return defaultFolderCell()
                }
            }
            
        } else {
            if indexPath.row < Menu.customFoldersCount {
                if customFolders.count > indexPath.row {
                    return customFolderCell()
                } else {
                    return defaultFolderCell()
                }
            } else {
                let cell = defaultFolderCell()
                if indexPath.row == Menu.customFoldersCount {
                    cell.textLabel?.textColor = k_redColor
                    cell.textLabel?.text = Strings.Menu.showMoreFolders.localized
                }
                return cell
            }
        }
    }
}
