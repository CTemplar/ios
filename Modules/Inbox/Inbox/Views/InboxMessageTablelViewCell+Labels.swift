import Foundation
import UIKit
import Utility
import Networking

extension InboxMessageTableViewCell {
    func setupLabelsAndImages(message: EmailMessage, header: String, subjectEncrypted: Bool) {
        
        if message.folder == Menu.sent.rawValue {
            if !message.receivers_display.isEmpty {
                let namesString = message.receivers_display.joined(separator: ", ")
                senderLabel.text = namesString
            } else if let receivers = message.receivers as? [String] {
                let namesString = receivers.joined(separator: ", ")
                senderLabel.text = namesString
            }
        } else {
            if let senderName = message.sender_display, !senderName.isEmpty {
                senderLabel.text = senderName
            } else if let sender = message.sender {
                senderLabel.text = sender
            }
        }
        
        if subjectEncrypted {
            encryptedSubjectView.isHidden = false
            subjectLabel.text = ""
        } else {
            encryptedSubjectView.isHidden = true
            if let subject = message.subject {
                subjectLabel.text = subject
            }
        }
        
        leftLabel.text = ""
        headMessageLabel.text = header
        
        if let createdDate = message.createdAt {
            if  let date = formatterService.formatStringToDate(date: createdDate) {
                timeLabel.text = formatterService.formatCreationDate(date: date, short: true)
            }
        }
        
        if let isRead = message.read {
            isReadImageView.isHidden = isRead
            if !isRead {
                senderLabel.font = AppStyle.SystemFontStyle.semiBold.font(withSize: 16.0)
                subjectLabel.font = AppStyle.CustomFontStyle.Bold.font(withSize: 14.0)
                backgroundColor = k_unreadMessageColor
            } else {
                senderLabel.font = AppStyle.SystemFontStyle.semiBold.font(withSize: 16.0)
                subjectLabel.font = AppStyle.CustomFontStyle.Bold.font(withSize: 14.0)
                backgroundColor = k_readMessageColor
            }
        }
        
        if let childrenCount = message.childrenCount {
            if childrenCount > 0 {
                countLabel.isHidden = false
                let totalCount = childrenCount + 1
                countLabel.text = totalCount.description
            } else {
                countLabel.isHidden = true
            }
        }
        
        leftlabelView.isHidden = true
        rightlabelView.isHidden = true
        leftLabel.textAlignment = .center
        
        let short = self.isShortNeed(message: message)
        let now = Date()
        
        if let delayedDelivery = message.delayedDelivery {
            leftlabelView.isHidden = false
            leftlabelView.backgroundColor = k_greenColor
            if let date = formatterService.formatDestructionTimeStringToDate(date: delayedDelivery) ??
                formatterService.formatDestructionTimeStringToDateTest(date: delayedDelivery) {
                if date <= now || (date.timeIntervalSince(now) < 120 && date.timeIntervalSince(now) > 0) {
                    leftLabel.attributedText = NSAttributedString(string: Strings.Inbox.inProgress.localized,
                                                                  attributes: [
                                                                    .font: AppStyle.CustomFontStyle.Regular.font(withSize: 9.0)!,
                                                                    .foregroundColor: UIColor.white,
                                                                    .kern: 0.0]
                    )
                } else {
                    leftLabel.attributedText = date.timeCountForDelivery(short: short)
                }
            } else {
                leftlabelView.isHidden = true
            }
        }
        
        if let deadManDuration = message.deadManDuration {
            leftlabelView.isHidden = false
            leftlabelView.backgroundColor = k_redColor
            let date = formatterService.formatDeadManDateString(duration: deadManDuration, short: short)
            leftLabel.attributedText = date
        }
        
        if let destructionDate = message.destructDay {
            leftlabelView.isHidden = false
            leftlabelView.backgroundColor = k_orangeColor
            if let date = formatterService.formatDestructionTimeStringToDate(date: destructionDate) ??
                formatterService.formatDestructionTimeStringToDateTest(date: destructionDate) {
                if date <= now || (date.timeIntervalSince(now) < 120 && date.timeIntervalSince(now) > 0) {
                    leftLabel.attributedText = NSAttributedString(string: Strings.Inbox.inProgress.localized,
                                                                  attributes: [.font: AppStyle.CustomFontStyle.Regular.font(withSize: 9.0)!,
                                                                               .foregroundColor: UIColor.white, .kern: 0.0]
                    )
                } else {
                    let attributedText = date.timeCountForDestruct(short: short)
                    leftLabel.attributedText = attributedText
                }
            } else {
                leftlabelView.isHidden = true
            }
        }
        
        if message.folder == Menu.trash.rawValue {
            leftlabelView.isHidden = true
            rightlabelView.isHidden = true
        }
        
        if let isSecured = message.isProtected {
            if isSecured {
                isSecuredImageView.image = #imageLiteral(resourceName: "SecureOn")
            } else {
                isSecuredImageView.image = #imageLiteral(resourceName: "SecureOff")
            }
        }
        
        if let isStarred = message.starred {
            if isStarred {
                isStaredImageView.image = #imageLiteral(resourceName: "StarOn")
            } else {
                isStaredImageView.image = #imageLiteral(resourceName: "StarOff")
            }
        }
        
        if let attachments = message.attachments {
            if attachments.count > 0 {
                hasAttachmentImageView.isHidden = false
            } else {
                hasAttachmentImageView.isHidden = true
            }
        }
    }
    
    func setupSenderLabelsAndBadgesView(short: Bool) {
        guard let sender = senderLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        let senderTextWidth = sender.widthOfString(usingFont: senderLabel.font) + 5.0
        
        let badgesViewWidth = calculateBadgesViewWidth(short: short)
        
        badgesViewWidthConstraint.constant = badgesViewWidth
        
        let availableSpace = cellWidth - badgesViewWidth - 120.0 - isSelectedImageTrailingConstraint.constant - isSelectedImageWidthConstraint.constant

        senderLabelWidthConstraint.constant = (senderTextWidth > availableSpace) ? availableSpace : senderTextWidth
    }
}
