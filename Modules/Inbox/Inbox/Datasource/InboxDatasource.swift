import Foundation
import UIKit
import Utility
import Networking
import MGSwipeTableCell

enum InboxFilter: CaseIterable {
    case starred
    case unread
    case attachments
    
    var localized: String {
        switch self {
        case .starred:
            return Strings.Inbox.Filter.starredFilter.localized
        case .unread:
            return Strings.Inbox.Filter.unreadFilter.localized
        case .attachments:
            return Strings.Inbox.Filter.attachmentsFilter.localized
        }
    }
}

final class InboxDatasource: NSObject {
    // MARK: Properties
    private var tableView: UITableView
    
    private weak var parentViewController: InboxViewController?
    
    private var messages: [EmailMessage]
    
    private var originalMessages: [EmailMessage] = []
    
    private var mailboxList: [Mailbox] = []
    
    private var selectedMessageIds: [Int] = []
    
    var selectionMode: Bool {
        return selectedMessageIds.isEmpty == false
    }
    
    private (set) var lastAppliedActionMessage: EmailMessage?
    
    private (set) var lastSelectedAction: Menu.Action?
    
    private (set) var unreadCount = 0
    
    private (set) var messageId = -1
    
    private let formatterService = UtilityManager.shared.formatterService
    
    private (set) var user = UserMyself()
    
    var messagesAvailable: Bool {
        return messages.isEmpty == false
    }
    
    var selectedMessagesCount: Int {
        return selectedMessageIds.count
    }
    
    var filterEnabled: Bool {
        return SharedInboxState.shared.appliedFilters.isEmpty == false
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        
        return refreshControl
    }()

    // MARK: - Constructor
    init(tableView: UITableView, parentViewController: InboxViewController, messages: [EmailMessage]) {
        self.tableView = tableView
        self.parentViewController = parentViewController
        self.messages = messages
        self.originalMessages = messages
        super.init()
        
        setupTableView()
        registerTableViewCell()
    }
    
    // MARK: - Setup
    func registerTableViewCell() {
        tableView.register(UINib(nibName: InboxMessageTableViewCell.className, bundle: Bundle(for: type(of: self))),
                           forCellReuseIdentifier: InboxMessageTableViewCell.className
        )
    }
    
    private func setupTableView() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        tableView.addGestureRecognizer(longPressRecognizer)
        
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.addSubview(self.refreshControl)
        
        parentViewController?.reloadButton.addTarget(self, action: #selector(handleRefresh(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc
    private func handleRefresh(_ sender: Any) {
        parentViewController?.presenter?.interactor?.update(offset: 0)
        parentViewController?
            .presenter?
            .interactor?
            .updateMessages(withUndo: "",
                            silent: sender is UIButton ? false : true,
                            menu: SharedInboxState.shared.selectedMenu)
    }
    
    @objc
    private func longPressed(sender: UILongPressGestureRecognizer) {
        guard SharedInboxState.shared.selectedMenu?.menuName != Menu.allMails.menuName else {
            return
        }
        
        if sender.state == .began {
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let message = messages[indexPath.row]
                DPrint("Long pressed row: \(indexPath.row)")
                if selectionMode == false {
                    selectedMessageIds.removeAll()
                    lastAppliedActionMessage = message
                    selectedMessageIds.append(message.messsageID!)
                    parentViewController?
                        .presenter?
                        .enableSelectionMode()
                }
            }
        }
    }
    
    func reload() {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func resetFooterView() {
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Datasource Handlers
    private func setupSwipeActionsButton() -> [MGSwipeButton] {
        var swipeButtonsArray: [MGSwipeButton] = []
        
        let trashButton = MGSwipeButton(title: "", icon: #imageLiteral(resourceName: "whiteTrash"), backgroundColor: k_sideMenuColor)
        let unreadButton = MGSwipeButton(title: "", icon: #imageLiteral(resourceName: "whiteUnread"), backgroundColor: k_sideMenuColor)
        let spamButton = MGSwipeButton(title: "", icon: #imageLiteral(resourceName: "whiteSpam"), backgroundColor: k_sideMenuColor)
        let moveToButton = MGSwipeButton(title: "", icon: #imageLiteral(resourceName: "whiteMoveTo"), backgroundColor: k_sideMenuColor)
        
        guard let menu = SharedInboxState.shared.selectedMenu as? Menu else {
            return []
        }
        
        switch menu {
        case .inbox,
             .sent,
             .outbox,
             .starred,
             .archive,
             .trash,
             .allMails,
             .unread,
             .manageFolders:
            swipeButtonsArray = [trashButton, moveToButton, spamButton]
        case .draft:
            swipeButtonsArray = [trashButton]
        case .spam:
            swipeButtonsArray = [trashButton, moveToButton, unreadButton]
        }
        
        return swipeButtonsArray
    }
    
    func needReadAction() -> Bool {
        for messageID in selectedMessageIds {
            if let message = messages.filter({ $0.messsageID == messageID }).first {
                if message.read == false {
                    return true
                }
            }
        }
        
        return false
    }
    
    func reset() {
        messages.removeAll()
        originalMessages.removeAll()
        resetSelectionMode()
        parentViewController?.presenter?.updateNoMessagePrompt()
    }
    
    func resetSelectionMode() {
        selectedMessageIds.removeAll()
    }
    
    func sortMessages() {
        messages.sort { [weak self] (msg1, msg2) -> Bool in
            guard let dateString1 = msg1.createdAt,
                let dateString2 = msg2.createdAt else {
                return false
            }
            
            guard let date1 = self?.formatterService.formatStringToDate(date: dateString1),
                let date2 = self?.formatterService.formatStringToDate(date: dateString2) else {
                return false
            }
            
            return date1 > date2
        }
    }
    
    func disableSelectionIfSelected() {
        parentViewController?.presenter?.disableSelectionMode()
    }
    
    func invokeRefreshUI() {
        let unreadEmailsCount = messages.filter({
            $0.read == false
        }).count
        
        parentViewController?
            .presenter?
            .setupUI(emailsCount: messages.count,
                     unreadEmails: unreadEmailsCount,
                     filterEnabled: filterEnabled
        )
    }
    
    func applyFilters() {
        if SharedInboxState.shared.appliedFilters.isEmpty {
            clearFilters()
            return
        }
        
        guard !messages.isEmpty else {
            return
        }
        
        var filteredMessages: [EmailMessage] = []
        
        SharedInboxState.shared.appliedFilters.forEach { (filter) in
            switch filter {
            case .unread:
                let filtered = originalMessages.filter({ $0.read == false })
                filteredMessages.append(contentsOf: filtered)
            case .starred:
                let filtered = originalMessages.filter({ $0.starred == true })
                filteredMessages.append(contentsOf: filtered)
            case .attachments:
                let filtered = originalMessages.filter({ $0.attachments?.isEmpty == false })
                filteredMessages.append(contentsOf: filtered)
            }
        }
        
        if !filteredMessages.isEmpty {
            messages = filteredMessages
            parentViewController?.presenter?.updateNoMessagePrompt()
            sortMessages()
        }
        
        // Reload Inbox
        reload()
    }
    
    func clearFilters() {
        messages = originalMessages
        sortMessages()
        parentViewController?.presenter?.updateNoMessagePrompt()
        
        // Reload Inbox
        reload()
    }
    
    func undo(lastMessage: EmailMessage) {
        parentViewController?.presenter?.hideUndoBar()

        guard selectedMessagesCount > 0 else {
            return
        }
        
        guard let lastAppliedAction = self.lastSelectedAction else {
            return
        }
        
        switch lastAppliedAction {
        case .markAsSpam:
            parentViewController?
                .presenter?
                .interactor?
                .markMessagesAsSpam(forMessageIds: selectedMessageIds,
                                    lastSelectedMessage: lastMessage,
                                    withUndo: ""
            )
        case .markAsRead:
            parentViewController?
                .presenter?
                .interactor?
                .toggleReadStatus(forMessageIds: selectedMessageIds,
                                  asRead: (lastMessage.read ?? false),
                                  withUndo: ""
            )
        case .moveToArchive:
            parentViewController?
                .presenter?
                .interactor?
                .markMessagesAsArchived(forMessageIds: selectedMessageIds,
                                        lastSelectedMessage: lastMessage,
                                        withUndo: ""
            )
        case .moveToTrash:
            parentViewController?
                .presenter?
                .interactor?
                .markMessagesAsTrash(forMessageIds: selectedMessageIds,
                                     lastSelectedMessage: lastMessage,
                                     withUndo: ""
            )
        case .markAsStarred,
             .moveToInbox,
             .moveTo,
             .delete,
             .noAction: break
        }
        
        update(lastSelectedAction: nil)
        selectedMessageIds.removeAll()
    }
    
    func showDetails(of message: EmailMessage) {
        messageId = -1
        if let menu = SharedInboxState.shared.selectedMenu {
            parentViewController?
                .router?
                .showViewInboxEmailViewController(message: message,
                                                  currentFolderFilter: menu.menuName,
                                                  user: user
            )
        }
    }
    
    func searchAttributes() -> (messages: [EmailMessage], user: UserMyself) {
        return (messages: messages, user: user)
    }
    
    // MARK: - Update Datasource
    func updateMessageStatus(message: EmailMessage, status: Bool) {
        if let index = messages.firstIndex(where: { $0.messsageID == message.messsageID }) {
            var message = messages[index]
            message.update(readStatus: status)
            messages[index] = message
            tableView.reloadData()
        }
        // Keep syncing the original messages by messages
        originalMessages = messages
    }

    func update(lastAppliedActionMessage: EmailMessage?) {
        self.lastAppliedActionMessage = lastAppliedActionMessage
    }
    
    func update(messages: [EmailMessage]) {
        messages.forEach { (message) in
            self.messages.removeAll(where: { $0.messsageID == message.messsageID })
            self.messages.append(message)
        }
        self.originalMessages = self.messages
        parentViewController?.presenter?.updateNoMessagePrompt()
    }
    
    func removeSelection() {
        selectedMessageIds.removeAll()
    }
    
    func update(filters: [InboxFilter]) {
        SharedInboxState.shared.update(appliedFilters: filters)
        applyFilters()
    }
    
    func update(unreadCount: Int) {
        self.unreadCount = unreadCount
    }
    
    func update(mailboxList: [Mailbox]) {
        self.mailboxList = mailboxList
    }
    
    func update(user: UserMyself) {
        self.user = user
    }
    
    func update(contacts: ContactsList) {
        self.user.update(contactsList: contacts.contactsList ?? [])
    }
    
    func update(lastSelectedAction: Menu.Action?) {
        self.lastSelectedAction = lastSelectedAction
    }
    
    func update(messageId: Int) {
        self.messageId = messageId
    }
    
    // MARK: - More Actions
    func toggleReadStatusOfSelectedMessage() {
        if let lastSelectedMessage = lastAppliedActionMessage {
            let readStatus = lastSelectedMessage.read ?? false
            let undoMessage = readStatus == false ?
            Strings.Inbox.UndoAction.undoMarkAsUnread.localized :
            Strings.Inbox.UndoAction.undoMarkAsRead.localized
            parentViewController?.presenter?.interactor?.toggleReadStatus(forMessageIds: selectedMessageIds,
                                                                          asRead: readStatus,
                                                                          withUndo: undoMessage
            )
        } else {
            DPrint("Messages are not selected")
        }
    }
    
    func moveMessagesToTrash() {
        guard let lastSelectedMessage = lastAppliedActionMessage else {
            DPrint("'lastAppliedActionMessage' is nil")
            return
        }
        
        if !selectedMessageIds.isEmpty {
            if SharedInboxState.shared.selectedMenu?.menuName == Menu.trash.menuName {
                deleteMessages()
            } else {
                parentViewController?
                    .presenter?
                    .interactor?
                    .markMessagesAsTrash(forMessageIds: selectedMessageIds,
                                         lastSelectedMessage: lastSelectedMessage,
                                         withUndo: Strings.Inbox.UndoAction.undoMoveToTrash.localized
                )
            }
        } else {
            DPrint("Messages are not selected")
        }
    }
    
    func deleteMessages() {
        if !selectedMessageIds.isEmpty {
            parentViewController?
                .presenter?
                .interactor?
                .delete(messageIds: selectedMessageIds,
                        withUndo: ""
            )
        } else {
            DPrint("Messages are not selected")
        }
    }
    
    func moveMessagesToArchive() {
        guard let lastSelectedMessage = lastAppliedActionMessage else {
            DPrint("'lastAppliedActionMessage' is nil")
            return
        }
        
        if !selectedMessageIds.isEmpty {
            parentViewController?
                .presenter?
                .interactor?
                .markMessagesAsArchived(forMessageIds: selectedMessageIds,
                                        lastSelectedMessage: lastSelectedMessage,
                                        withUndo: Strings.Inbox.UndoAction.undoMoveToArchive.localized
            )
        } else {
            DPrint("Messages are not selected")
        }
    }
    
    func moveMessagesToInbox() {
        guard let lastSelectedMessage = lastAppliedActionMessage else {
            DPrint("'lastAppliedActionMessage' is nil")
            return
        }
        
        if !selectedMessageIds.isEmpty {
            parentViewController?
                .presenter?
                .interactor?
                .moveMessagesToInbox(messageIds: selectedMessageIds,
                                     lastSelectedMessage: lastSelectedMessage,
                                     withUndo: Strings.Inbox.UndoAction.undoMoveToInbox.localized
            )
        } else {
            DPrint("Messages are not selected")
        }
    }
    
    func moveMessagesToSpam() {
        guard let lastSelectedMessage = lastAppliedActionMessage else {
            DPrint("'lastAppliedActionMessage' is nil")
            return
        }
        
        if !selectedMessageIds.isEmpty {
            parentViewController?
                .presenter?
                .interactor?
                .markMessagesAsSpam(forMessageIds: selectedMessageIds,
                                    lastSelectedMessage: lastSelectedMessage,
                                    withUndo: Strings.Inbox.UndoAction.undoMarkAsSpam.localized
            )
        } else {
            DPrint("Messages are not selected")
        }
    }
    
    func moveTo() {
        parentViewController?.router?.showMoveToController(withSelectedMessages: selectedMessageIds)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension InboxDatasource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureMailCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        let totalItems = parentViewController?.presenter?.interactor?.totalItems ?? 0
        
        if indexPath.section == lastSectionIndex,
            indexPath.row == lastRowIndex,
            messages.count < totalItems {
                        
            parentViewController?
                .presenter?
                .interactor?
                .toggleProgress(true)
            
            if let menu = SharedInboxState.shared.selectedMenu {
                let fetchRequired = parentViewController?
                    .presenter?
                    .interactor?
                    .messagesList(folder: menu.menuName,
                                  withUndo: "",
                                  silent: true
                )
                
                if fetchRequired == true {
                    let spinner = MatericalIndicator.shared.loader(with: CGSize(width: 50.0, height: 50.0))
                    tableView.tableFooterView = spinner
                    spinner.startAnimating()
                } else {
                    tableView.tableFooterView = UIView()
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let message = messages[indexPath.row]
        
        if selectionMode == false {
            if SharedInboxState.shared.selectedMenu?.menuName == Menu.draft.menuName {
                parentViewController?
                    .router?
                    .showComposeViewController(answerMode: .newMessage,
                                               message: message,
                                               user: user
                )
            } else {
                if let menu = SharedInboxState.shared.selectedMenu {
                    parentViewController?
                        .router?
                        .showViewInboxEmailViewController(message: message,
                                                          currentFolderFilter: menu.menuName,
                                                          user: user
                    )
                }
            }
        } else {
            let selected = selectedMessageIds.filter({ $0 == message.messsageID }).isEmpty == false
            
            if selected {
                if let index = selectedMessageIds.firstIndex(where: {$0 == message.messsageID}) {
                    DPrint("deselected")
                    selectedMessageIds.remove(at: index)
                }
            } else {
                DPrint("selected")
                selectedMessageIds.append(message.messsageID!)
                lastAppliedActionMessage = message
            }
            
            if selectedMessageIds.isEmpty {
                parentViewController?.presenter?.disableSelectionMode()
            }
            
            reload()
            
            parentViewController?
                .presenter?
                .updateNavigationBarTitle(basedOnMessageCount: selectedMessagesCount,
                                          selectionMode: selectionMode,
                                          currentFolder: SharedInboxState.shared.selectedMenu ?? Menu.inbox
            )
        }
    }
    
    private func configureMailCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InboxMessageTableViewCell.className,
                                                       for: indexPath) as? InboxMessageTableViewCell else {
            return UITableViewCell()
        }
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        
        cell.rightButtons = setupSwipeActionsButton()
        cell.delegate = self
        
        let message = messages[indexPath.row]
        let selected = selectedMessageIds.filter({ $0 == message.messsageID }).isEmpty == false
        
        let isSubjectEncrypted = NetworkManager.shared.apiService.isSubjectEncrypted(message: message)
        
        cell.setupCellWithData(message: message, header: "", subjectEncrypted: isSubjectEncrypted, isSelectionMode: selectionMode, isSelected: selected, frameWidth: tableView.frame.width)
        return cell
    }
}

// MARK: - MGSwipeTableCellDelegate
extension InboxDatasource: MGSwipeTableCellDelegate {
    func swipeTableCell(_ cell: MGSwipeTableCell, didChange state: MGSwipeState, gestureIsActive: Bool) {
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        return selectionMode ? false : true
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return true
        }
        
        let message = messages[indexPath.row]
        
        guard let id = message.messsageID else {
            return true
        }
        
        // Needed for undo action
        lastAppliedActionMessage = message
        
        selectedMessageIds.removeAll()
        selectedMessageIds.append(id)
        
        guard let menu = SharedInboxState.shared.selectedMenu as? Menu else {
            return true
        }
        
        switch menu {
        case .inbox,
             .sent,
             .outbox,
             .starred,
             .archive,
             .trash,
             .allMails,
             .unread,
             .manageFolders:
            generalSwipeAction(index: index, message: message)
        case .draft:
            draftSwipeAction(index: index, message: message)
        case .spam:
            spamSwipeAction(index: index, message: message)
        }
        return true
    }
}

// MARK: - Swipe Actions
private extension InboxDatasource {
    func generalSwipeAction(index: Int, message: EmailMessage) {
        switch index {
        case InboxCellButtonsIndex.right.rawValue:
            DPrint("trash tapped")
            parentViewController?.presenter?.interactor?.markMessageAsTrash(message: message)
        case InboxCellButtonsIndex.middle.rawValue:
            DPrint("move to tapped")
            parentViewController?.presenter?.interactor?.showMoveTo(message: message)
        case InboxCellButtonsIndex.left.rawValue:
            DPrint("spam tapped")
            parentViewController?.presenter?.interactor?.markMessageAsSpam(message: message)
        default: break
        }
    }
    
    func draftSwipeAction(index: Int, message: EmailMessage) {
        switch index {
        case InboxCellButtonsIndex.right.rawValue:
            DPrint("trash tapped")
            parentViewController?.presenter?.interactor?.markMessageAsTrash(message: message)
        case InboxCellButtonsIndex.middle.rawValue:
            break
        case InboxCellButtonsIndex.left.rawValue:
            break
        default:
            break
        }
    }
    
    func spamSwipeAction(index: Int, message: EmailMessage) {
        switch index {
        case InboxCellButtonsIndex.right.rawValue:
            DPrint("trash tapped")
            parentViewController?.presenter?.interactor?.markMessageAsTrash(message: message)
        case InboxCellButtonsIndex.middle.rawValue:
            DPrint("move to tapped")
            parentViewController?.presenter?.interactor?.showMoveTo(message: message)
        case InboxCellButtonsIndex.left.rawValue:
            DPrint("read tapped")
            parentViewController?.presenter?.interactor?.markMessageAsRead(message: message)
        default: break
        }
    }
}