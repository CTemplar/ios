import Utility
import UIKit
import InboxViewer

extension ComposeController {
    func configureFromCell(at indexPath: IndexPath) -> UITableViewCell {
       func setup(cell: ComposeMailFromEmailCell) {
            guard let vm = viewModel.cellViewModel(at: indexPath) else {
                return
            }
            cell.onTapDown = { [weak self] (selectedMailId) in
                guard let safeSelf = self else {
                    return
                }
                
                let rect = safeSelf.tableView.rectForRow(at: indexPath)
                let rectInScreen = safeSelf.tableView.convert(rect, to: safeSelf.tableView.superview)
                safeSelf.showMailBoxes(safeSelf.viewModel.mailboxList,
                                       rect: rectInScreen,
                                       selectMailId: selectedMailId,
                                       onUpdateMailAddress:
                    { (mailAddress) in
                        cell.model?.update(mailId: mailAddress ?? "")
                        safeSelf.tableView.reloadRows(at: [indexPath], with: .automatic)
                })
            }
            cell.configure(with: vm)
        }
        
        guard let cell =
            tableView
                .dequeueReusableCell(withIdentifier: ComposeMailFromEmailCell.className,
                                     for: indexPath) as? ComposeMailFromEmailCell
            else {
                let cellObject = ComposeMailFromEmailCell(style: .default,
                                                          reuseIdentifier: ComposeMailFromEmailCell.className)
                setup(cell: cellObject)
                return cellObject
        }
        setup(cell: cell)
        return cell
    }

    func configurePrefixCell(at indexPath: IndexPath, with identifier: String) -> UITableViewCell {
        
        func setup(cell: ComposeMailOtherEmailCell) {
            guard let vm = viewModel.cellViewModel(at: indexPath) else {
                return
            }
            
            cell.onTapMore = { [weak self] in
                self?.viewModel.updateCollapseState()
                self?.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
            
            cell.configure(with: vm)
        }
        
        guard let cell =
            tableView
                .dequeueReusableCell(withIdentifier: identifier,
                                     for: indexPath) as? ComposeMailOtherEmailCell
            else {
                let cellObject = ComposeMailOtherEmailCell(style: .default,
                                                           reuseIdentifier: identifier)
                setup(cell: cellObject)
                return cellObject
        }
        
        setup(cell: cell)
        
        return cell
    }

    func configureSubjectCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let vm = viewModel.cellViewModel(at: indexPath) else {
            return UITableViewCell()
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: ComposeMailSubjectCell.className,
                                                 for: indexPath) as? ComposeMailSubjectCell
        if cell == nil {
            cell = ComposeMailSubjectCell(style: .default,
                                          reuseIdentifier: ComposeMailSubjectCell.className)
        }

        cell!.configure(with: vm)
        return cell!
    }

    func configureMenuCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
            tableView
                .dequeueReusableCell(withIdentifier: ComposeMailMenuCell.className,
                                     for: indexPath) as? ComposeMailMenuCell
            else {
                let cellObject = ComposeMailMenuCell(style: .default,
                                                     reuseIdentifier: ComposeMailMenuCell.className)
                setupMenuCell(cellObject, at: indexPath)
                return cellObject
        }
        
        setupMenuCell(cell, at: indexPath)
        return cell
    }
    
    private func setupMenuCell(_ cell: ComposeMailMenuCell, at indexPath: IndexPath) {
        guard let vm = viewModel.cellViewModel(at: indexPath) else {
            return
        }
        
        cell.configure(with: vm)
        
        cell.onTapAttachment = { [weak self] (sender, isAlreadySelected) in
            self?.view.endEditing(true)
            self?.onTapAttachment(sender, onCompletion: { (url) in
                self?.viewModel.updateAttachment(withURL: url)
            })
        }
        
        cell.onTapDestruction = { [weak self] (isAlreadySelected) in
            self?.view.endEditing(true)
            self?.onTapSchedulerMenu(with: .selfDestructTimer,
                                     menu: .selfDesctructionTimer,
                                     alreadySelected: isAlreadySelected)
        }
        
        cell.onTapDeadManTimer = { [weak self] (isAlreadySelected) in
            self?.view.endEditing(true)
            self?.onTapSchedulerMenu(with: .deadManTimer,
                                     menu: .deadManTimer,
                                     alreadySelected: isAlreadySelected)
        }
        
        cell.onTapDelayDelivery = { [weak self] (isAlreadySelected) in
            self?.view.endEditing(true)
            self?.onTapSchedulerMenu(with: .delayedDelivery,
                                     menu: .delayedDelivery,
                                     alreadySelected: isAlreadySelected)
        }
        
        cell.onTapMailEncryption = { [weak self] (isAlreadySelected) in
            self?.view.endEditing(true)
            if isAlreadySelected {
                self?.viewModel.updateMenu(state: !isAlreadySelected, by: .mailEncryption)
            } else {
                self?.router.showSetPasswordViewController({ (password, hint, hours) in
                    self?.viewModel.sendPasswordWhileCreatingMail(withPassword: password,
                                                                  hint: hint,
                                                                  expiryHours: hours,
                                                                  onCompletion:
                        { (isCompleted) in
                            DispatchQueue.main.async {
                                self?.viewModel.updateMenu(state: isCompleted, by: .mailEncryption)
                            }
                    })
                })
            }
        }
    }
    
    private func onTapSchedulerMenu(with mode: SchedulerMode, menu: ComposeMailMenu, alreadySelected: Bool) {
        if alreadySelected {
            viewModel.modifyScheduledDates(from: nil, withMode: mode)
            viewModel.updateMenu(state: false, by: menu)
        } else {
            let existingDate = viewModel.formattedDate(for: mode)
            router.showSchedulerViewController(mode: mode,
                                               existingDate: existingDate,
                                               onCompletion:
                { [weak self] (selectedMode, selectedDate) in
                    self?.viewModel.modifyScheduledDates(from: selectedDate, withMode: selectedMode)
                    self?.viewModel.updateMenu(state: true, by: menu)
            })
        }
    }
    
    func configureAttachmentCell(at indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: AttachmentCell.className,
                                                 for: indexPath) as? AttachmentCell
        if cell == nil {
            cell = AttachmentCell(style: .default,
                                  reuseIdentifier: ComposeMailSubjectCell.className)
        }

        return setupAttachmentCell(cell!, at: indexPath)
    }
    
    private func setupAttachmentCell(_ cell: AttachmentCell, at indexPath: IndexPath) -> UITableViewCell {
        guard let vm = viewModel.cellViewModel(at: indexPath) else {
            return UITableViewCell()
        }
        
        cell.configure(with: vm)
        
        // Attachment Handler
        cell.onTapAttachment = { [weak self] (contentURLString, encrypted) in
            let url = FileManager.getFileUrlDocuments(withURLString: contentURLString)
            if FileManager.checkIsFileExist(url: url) == true {
                self?.showPreviewScreen(url: url, encrypted: encrypted)
            } else {
                self?.loadAttachFile(url: contentURLString, encrypted: encrypted)
            }
        }
        
        cell.onDeleteAttachment = { [weak self] (contentURLString) in
            self?.showAttachmentDeleteAlert({ (shouldDelete) in
                self?.viewModel.removeAttachment(with: contentURLString)
            })
        }
        
        return cell
    }
    
    func showAttachmentDeleteAlert(_ onCompletion: @escaping ((Bool) -> Void)) {
        let alert = UIAlertController(title: Strings.Compose.removeAttachmentAlertTitle.localized,
                                      message: Strings.Compose.removeAttachmentAlertDesc.localized,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: Strings.Button.yesActionTitle.localized,
                              style: .destructive,
                              handler: { (_) in
                                onCompletion(true)
        }))
        
        alert.addAction(.init(title: Strings.Button.noActionTitle.localized,
                              style: .cancel,
                              handler: { (_) in
                                onCompletion(false)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func configureBodyCell(at indexPath: IndexPath) -> UITableViewCell {
        func setup(cell: ComposeMailBodyCell) {
            guard let vm = viewModel.cellViewModel(at: indexPath) else {
                return
            }

            cell.configure(with: vm)
        }
        
        guard let cell =
            tableView
                .dequeueReusableCell(withIdentifier: ComposeMailBodyCell.className,
                                     for: indexPath) as? ComposeMailBodyCell
            else {
                let cellObject = ComposeMailBodyCell(style: .default,
                                                     reuseIdentifier: ComposeMailBodyCell.className)
                setup(cell: cellObject)
                return cellObject
        }
        
        setup(cell: cell)
        
        return cell
    }
}
