import Foundation
import UIKit
import Utility
import Networking

extension InboxMessageTableViewCell {
    func setupLabelsAndImages(message: EmailMessage, subjectEncrypted: Bool) {
        
        senderLabel.font = .withType(.Default(.Bold))
        
        if message.folder == Menu.sent.rawValue {
            if !message.receivers_display.isEmpty {
                let namesString = message.receivers_display.joined(separator: ", ")
                senderLabel.text = namesString
            } else if let receivers = message.receivers {
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
            subjectLabel.text = Strings.Inbox.mailEncryptedMessage.localized
            subjectLabel.font = .withType(.Large(.Bold))
        } else {
            subjectLabel.font = .withType(.Large(.Normal))
            let subject = message.subject ?? ""
            if subject.contains("BEGIN PGP") == true, let decryptedSubject = decrypt(content: subject) {
                subjectLabel.text = decryptedSubject
            } else {
                subjectLabel.text = subject
            }
        }

        leftLabel.text = ""
        
        if let createdDate = message.createdAt {
            if  let date = formatterService.formatStringToDate(date: createdDate) {
                timeLabel.text = formatterService.formatCreationDate(date: date, short: true)
            }
        }
        
        isReadView.isHidden = message.read == true
        
        if let childrenCount = message.childrenCount {
            let totalCount = childrenCount + 1
            countLabel.text = totalCount.description
            countLabel.isHidden = childrenCount < 1
        }
        
        leftlabelView.isHidden = true
        
        rightlabelView.isHidden = true
        
        leftLabel.textAlignment = .center
        
        let short = isShortNeed(message: message)
        let now = Date()
        
        if let delayedDelivery = message.delayedDelivery {
            leftlabelView.isHidden = false
            leftlabelView.backgroundColor = k_greenColor
            if let date = formatterService.formatDestructionTimeStringToDate(date: delayedDelivery) ??
                formatterService.formatDestructionTimeStringToDateTest(date: delayedDelivery) {
                if date <= now || (date.timeIntervalSince(now) < 120 && date.timeIntervalSince(now) > 0) {
                    leftLabel.attributedText = NSAttributedString(string: Strings.Inbox.inProgress.localized,
                                                                  attributes: [
                                                                    .font: UIFont.withType(.ExtraSmall(.Normal)),
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
                                                                  attributes: [.font: UIFont.withType(.ExtraSmall(.Normal)),
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
        
        isSecuredImageView.image = message.isProtected == true ? UIImage(systemName: "lock.fill") : UIImage(systemName: "lock.slash.fill")
        
        isStaredImageView.image = message.starred == true ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")

        hasAttachmentImageView.isHidden = message.attachments?.isEmpty == true
    }

    private func decrypt(content: String) -> String? {
        let decryptedSubject = UtilityManager.shared.pgpService.decryptMessage(encryptedContet: content)
        if decryptedSubject == "#D_FAILED_ERROR#" {
            return nil
        }
        return decryptedSubject
    }
    
    func isShortNeed(message: EmailMessage) -> Bool {
        var short = false
        var leftLabelShowing = false
        
        if Device.IS_IPHONE_5 {
            short = true
        } else {
            if message.delayedDelivery != nil || message.deadManDuration != nil {
                leftLabelShowing = true
            }
            
            if message.destructDay != nil, leftLabelShowing {
                short = true
            }
        }
        return short
    }
}
