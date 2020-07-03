import Foundation
import Utility
import UIKit
import SideMenu

final class InboxPresenter {
    // MARK: Properties
    private (set) var interactor: InboxInteractor?
    private (set) weak var viewController: InboxViewController?
    private var timer: Timer?
    private var counter = 0
    
    // MARK: - Constructor
    init(interactor: InboxInteractor?,
         viewController: InboxViewController) {
        self.interactor = interactor
        self.viewController = viewController
    }
    
    // MARK: - UI Setup
    func setupUI(emailsCount: Int,
                 unreadEmails: Int,
                 filterEnabled: Bool) {
        if filterEnabled {
            viewController?.messagesLabel.text = Strings.Inbox.filtered.localized
            viewController?.unreadMessagesLabel.text = formatAppliedFilters()
            viewController?.unreadMessagesLabel.textColor = k_redColor
            viewController?.inboxEmptyLabel.text = Strings.Inbox.noFilteredMessage.localized
            viewController?.inboxEmptyImageView.image = #imageLiteral(resourceName: "EmptyFilterInboxIcon")
        } else {
            viewController?.messagesLabel.text = formatEmailsCountText(emailsCount: emailsCount)
            viewController?.unreadMessagesLabel.text = formatUreadEmailsCountText(emailsCount: unreadEmails)
            viewController?.unreadMessagesLabel.textColor = k_lightGrayTextColor
            viewController?.inboxEmptyLabel.text = Strings.Inbox.noInboxMessage.localized
            viewController?.inboxEmptyImageView.image = #imageLiteral(resourceName: "EmptyInboxIcon")
        }

        viewController?.toggleGeneralToolbar(shouldShow: emailsCount > 0)
        
        updateNavigationBarTitle(basedOnMessageCount: viewController?.dataSource?.selectedMessagesCount ?? 0,
                                 selectionMode: viewController?.dataSource?.selectionMode ?? false,
                                 currentFolder: viewController?.selectedMenu ?? .inbox
        )
        
        updateRightNavigationItems(basedOn: viewController?.dataSource?.selectionMode ?? false)
        
        viewController?.noMessagePromptStackView.isHidden = viewController?.dataSource?.messagesAvailable == false
    }
    
    func updateNavigationBarTitle(basedOnMessageCount selectedMessages: Int,
                                  selectionMode: Bool,
                                  currentFolder: Menu) {
        viewController?.navigationController?.navigationBar.isHidden = false
        
        viewController?.title = selectionMode ? "\(selectedMessages) \(Strings.Inbox.selected.localized)" : currentFolder.localized
    }
    
    func updateLeftNavigationItem(basedOn selectionMode: Bool) {
        if selectionMode {
            viewController?.navigationItem.leftBarButtonItem = nil
        } else {
            let menuItem = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"), style: .plain, target: self, action: #selector(onTapMenu))
            viewController?.navigationItem.leftBarButtonItem = menuItem
        }
    }
    
    func updateRightNavigationItems(basedOn selectionMode: Bool) {
        if selectionMode {
            let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onTapCancel))
            viewController?.navigationItem.rightBarButtonItem = cancelItem
        } else {
            let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(onTapSearch))
            viewController?.navigationItem.rightBarButtonItem = searchItem
        }
    }
    
    // MARK: - UI Formatting
    private func formatAppliedFilters() -> String {
        var appliedFiltersText = ""
        for filter in viewController?.dataSource?.appliedFilters ?? [] {
            switch filter {
            case .starred:
                appliedFiltersText = appliedFiltersText.isEmpty ?
                    Strings.Inbox.Filter.starredFilter.localized :
                "\(appliedFiltersText), \(Strings.Inbox.Filter.starredFilter.localized)"
            case .unread:
                appliedFiltersText = appliedFiltersText.isEmpty ?
                    Strings.Inbox.Filter.unreadFilter.localized :
                "\(appliedFiltersText), \(Strings.Inbox.Filter.unreadFilter.localized)"
            case .attachments:
                appliedFiltersText = appliedFiltersText.isEmpty ?
                    Strings.Inbox.Filter.attachmentsFilter.localized :
                "\(appliedFiltersText), \(Strings.Inbox.Filter.attachmentsFilter.localized)"
            }
        }
        return appliedFiltersText
    }
    
    private func formatEmailsCountText(emailsCount: Int) -> String {
        var emailsCountString = Strings.Inbox.emails.localized
        
        var lastDigit = 0
        
        if emailsCount < 10 || emailsCount > 19 {
            let daysString = emailsCount.description
            if let lastChar = daysString.last {
                lastDigit = Int(String(lastChar)) ?? 0
            }
        } else {
            lastDigit = emailsCount
        }
        
        if lastDigit > 0 {
            if lastDigit > 1 {
                emailsCountString = Strings.Inbox.emails.localized
                if lastDigit < 5 {
                    emailsCountString = Strings.Inbox.emailsx.localized
                }
            } else {
                emailsCountString = Strings.Inbox.email.localized
            }
        }
        
        emailsCountString = "\(emailsCount.description) \(emailsCountString)"
        
        return emailsCountString
    }
    
    private func formatUreadEmailsCountText(emailsCount: Int) -> String {
        var emailsCountString = Strings.Inbox.unread.localized
        emailsCountString = "\(emailsCount.description) \(emailsCountString)"
        return emailsCountString
    }
    
    // MARK: - Actions
    @objc
    private func onTapSearch() {
        viewController?.router?.showSearchViewController()
    }
    
    @objc
    private func onTapCancel() {
        disableSelectionMode()
        viewController?.dataSource?.update(lastAppliedActionMessage: nil)
        viewController?.dataSource?.removeSelection()
    }
    
    @objc
    private func onTapMenu() {
        viewController?.sideMenuController?.revealMenu()
    }
        
    func enableSelectionMode() {
        // Switch on selection mode
        viewController?
            .dataSource?
            .update(selectionMode: true)
        
        // Reload Datasource
        viewController?
            .dataSource?
            .reload()
        
        // Update Navigation Bar buttons
        updateLeftNavigationItem(basedOn: viewController?.dataSource?.selectionMode ?? false)
        
        updateRightNavigationItems(basedOn: viewController?.dataSource?.selectionMode ?? false)
        
        // Update Tool bars
        if self.viewController?.selectedMenu == .draft {
            viewController?.turnOnDraftToolBar()
        } else {
            viewController?.turnOnSelectionToolBar()
        }
        
        // Update navigation title
        updateNavigationBarTitle(basedOnMessageCount: viewController?.dataSource?.selectedMessagesCount ?? 0,
                                 selectionMode: viewController?.dataSource?.selectionMode ?? false,
                                 currentFolder: viewController?.selectedMenu ?? .inbox
        )
    }
    
    func disableSelectionMode() {
        // Switch off selection mode
        viewController?
            .dataSource?
            .update(selectionMode: false)
        
        // Reload Datasource
        viewController?
            .dataSource?
            .reload()
        
        // Update Navigation Bar buttons
        updateLeftNavigationItem(basedOn: viewController?.dataSource?.selectionMode ?? false)
        
        updateRightNavigationItems(basedOn: viewController?.dataSource?.selectionMode ?? false)
        
        // Update Tool bars
        viewController?.toggleGeneralToolbar(shouldShow: true)
        
        // Update navigation title
        updateNavigationBarTitle(basedOnMessageCount: viewController?.dataSource?.selectedMessagesCount ?? 0,
                                 selectionMode: viewController?.dataSource?.selectionMode ?? false,
                                 currentFolder: viewController?.selectedMenu ?? .inbox
        )
    }
    
    // MARK: - Toolbar Actions
    func showMoreActions() {
        showMoreActionsAlert()
    }

    func showFilterView(from sender: UIBarButtonItem) {
        let inboxFilterVC: InboxFilterViewController = UIStoryboard(storyboard: .inboxFilter,
                                                                    bundle: Bundle(for: type(of: self))
        ).instantiateViewController()
        
        inboxFilterVC.onApplyFilters = { [weak self] (appliedFilters) in
            self?.viewController?.dataSource?.update(filters: appliedFilters)
            self?.setupUI(emailsCount: self?.interactor?.totalItems ?? 0,
                          unreadEmails: self?.viewController?.dataSource?.unreadCount ?? 0,
                          filterEnabled: self?.viewController?.dataSource?.filterEnabled ?? false)
        }
        
        if Device.IS_IPHONE {
            inboxFilterVC.modalPresentationStyle = .formSheet
            viewController?.present(inboxFilterVC, animated: true, completion: nil)
        } else {
            inboxFilterVC.modalPresentationStyle = .popover
            let popover = inboxFilterVC.popoverPresentationController
            popover?.barButtonItem = sender
            viewController?.present(inboxFilterVC, animated: true, completion:nil)
        }
    }
}

// MARK: - Undo Actions
extension InboxPresenter {
    func showUndoBar(text: String) {
        DPrint("show undo bar")
        viewController?.turnOnUndoToolbar()
        viewController?.undoBarButtonItem.title = text
        counter = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fadeUndoBar), userInfo: nil, repeats: true)
    }
    
    @objc
    private func fadeUndoBar() {
        counter +=  1
        
        let alpha = 1.0/Double(counter)
        
        viewController?.undoToolBar.alpha = CGFloat(alpha)
        
        if counter == undoActionDuration {
            hideUndoBar()
            
            viewController?
                .dataSource?
                .update(lastAppliedActionMessage: nil)
            
            viewController?
                .dataSource?
                .removeSelection()
        }
    }
    
    private func hideUndoBar() {
        counter = 0
        timer?.invalidate()
        timer = nil
        viewController?.toggleGeneralToolbar(shouldShow: true)
        viewController?.undoToolBar.alpha = 1.0
    }
}

// MARK: - More Actions
extension InboxPresenter {
    private func showMoreActionsAlert() {
        var actions: [MoreAction] = []
        
        let menu = viewController?.selectedMenu ?? .inbox
        
        let readableAction: MoreAction = (viewController?.dataSource?.needReadAction() == true) ? .markAsRead : .markAsUnread
        
        switch menu {
        case .inbox,
             .sent:
            actions.append(contentsOf: [
                readableAction,
                .moveToArchive,
                .cancel
                ]
            )
        case .allMails:
            actions.append(contentsOf: [
                .markAsSpam,
                .moveToTrash
                ]
            )
        case .outbox,
             .trash,
             .starred,
             .manageFolders:
            actions.append(contentsOf: [
                readableAction,
                .moveToArchive,
                .moveToInbox,
                .cancel
                ]
            )
        case .archive,
             .spam:
            actions.append(contentsOf: [
                .moveToArchive,
                 .moveToInbox,
                 .cancel
                ]
            )
        case .draft:
            actions = []
        }
        
        let actionSheet = UIAlertController(title: Strings.Inbox.MoreAction.moreActions.localized,
                                            message: nil,
                                            preferredStyle: .actionSheet
        )

        for action in actions {
            let alertAction = UIAlertAction(title: action.localized,
                                            style: action == .cancel ?
                                                .destructive :
                                                .default,
                                            handler: { [weak self] (_) in
                                                switch action {
                                                case .moveToInbox:
                                                    self?.moveToInbox()
                                                case .moveToArchive:
                                                    self?.moveToArchive()
                                                case .markAsRead, .markAsUnread:
                                                    self?.toggleMessageStatus()
                                                case .markAsSpam:
                                                    self?.markAsSpam()
                                                case .cancel:
                                                    actionSheet.dismiss(animated: true, completion: nil)
                                                default:
                                                    DPrint("Do Nothing")
                                                }
            })
            actionSheet.addAction(alertAction)
        }
        
        viewController?.present(actionSheet, animated: true, completion: nil)
    }
    
    func moveToInbox() {
        let params = AlertKitParams(
            title: Strings.Inbox.Alert.deleteTitle.localized,
            message: Strings.Inbox.Alert.deleteMessage.localized,
            cancelButton: Strings.Button.cancelButton.localized,
            otherButtons: [
                Strings.Button.deleteButton.localized
            ]
        )
        viewController?
            .dataSource?
            .moveMessagesToInbox()
    }
    
    func moveToArchive() {
        viewController?
            .dataSource?
            .moveMessagesToArchive()
    }
    
    func toggleMessageStatus() {
        viewController?
            .dataSource?
            .toggleReadStatusOfSelectedMessage()
    }

    func markAsSpam() {
        viewController?
            .dataSource?
            .moveMessagesToSpam()
    }
    
    func deleteMessagesPermanently() {
        let params = AlertKitParams(
            title: Strings.Inbox.Alert.deleteTitle.localized,
            message: Strings.Inbox.Alert.deleteMessage.localized,
            cancelButton: Strings.Button.cancelButton.localized,
            otherButtons: [
                Strings.Button.deleteButton.localized
            ]
        )
        
        viewController?.showAlert(with: params, onCompletion: { [weak self] (index) in
            switch index {
            case 0:
                DPrint("Cancel Delete")
            default:
                DPrint("Delete")
                self?.viewController?
                    .dataSource?
                    .deleteMessages()
            }
        })
    }
}
