import Foundation
import UIKit
import Utility
import Networking
import SwipeCellKit

// MARK: - Swipe Actions Configurations
extension InboxDatasource {
    func leftSwipeAction(for indexPath: IndexPath) -> [SwipeAction]? {
        guard messages.count > indexPath.row else {
            return nil
        }
        
        guard let menu = SharedInboxState.shared.selectedMenu as? Menu, menu == .inbox else {
            return nil
        }
        
        let email = messages[indexPath.row]
        
        let read = SwipeAction(style: .default, title: nil) { [weak self] (action, indexPath) in
            let updatedStatus = email.read == true ? false : true
            self?.parentViewController?.presenter?.toggleMessageStatus(readStatus: updatedStatus,
                                                                       for: [email.messsageID!])
        }
        
        read.hidesWhenSelected = true
        
        let descriptor: ActionDescriptor = email.read == true ? .unread : .read
        
        configure(action: read, with: descriptor)
        
        return [read]
    }
    
    func rightSwipeAction(for indexPath: IndexPath) -> [SwipeAction]? {
        guard messages.count > indexPath.row else {
            return nil
        }
        
        guard let menu = SharedInboxState.shared.selectedMenu as? Menu else {
            return nil
        }
        
        let email = messages[indexPath.row]
        
        let trashAction = SwipeAction(style: .default, title: nil) { [weak self] (action, indexPath) in
            self?.parentViewController?.presenter?.interactor?.markMessageAsTrash(message: email)
        }
        
        trashAction.hidesWhenSelected = true
        configure(action: trashAction, with: .trash)
        
        let spamAction = SwipeAction(style: .default, title: nil) { [weak self] (action, indexPath) in
            self?.parentViewController?.presenter?.interactor?.markMessageAsSpam(message: email)
        }
        
        spamAction.hidesWhenSelected = true
        configure(action: spamAction, with: .spam)
        
        let moveToAction = SwipeAction(style: .default, title: nil) { [weak self] (action, indexPath) in
            self?.parentViewController?.presenter?.interactor?.showMoveTo(message: email)
        }
        
        moveToAction.hidesWhenSelected = true
        configure(action: moveToAction, with: .moveTo)
        
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
            return [trashAction, moveToAction, spamAction]
        case .draft:
            return [trashAction]
        case .spam:
            return [trashAction, moveToAction]
        }
    }
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: .titleAndImage)
        action.image = descriptor.image(forStyle: .circular, displayMode: .titleAndImage)
        action.backgroundColor = .clear
        action.textColor = descriptor.color(forStyle: .circular)
        action.font = .withType(.ExtraSmall(.Bold))
        action.transitionDelegate = ScaleTransition.default
    }
}

extension InboxDatasource: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        switch orientation {
        case .left:
            return leftSwipeAction(for: indexPath)
        case .right:
            return rightSwipeAction(for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        options.transitionStyle = defaultOptions.transitionStyle
        options.buttonSpacing = 4
        options.backgroundColor = .clear
        return options
    }
}
