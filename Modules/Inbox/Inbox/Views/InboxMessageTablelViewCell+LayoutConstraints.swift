import Foundation
import UIKit
import Utility
import Networking

extension InboxMessageTableViewCell {
    func setupConstraints(message: EmailMessage, isSelectionMode: Bool) {
        
        isSelectedImageTrailingConstraint.constant = isSelectionMode ? 12.0 : 0.0
        isSelectedImageWidthConstraint.constant = isSelectionMode ? 22.0 : 0.0
        
        dotImageWidthConstraint.constant = message.read == true ? 0.0 : 6.0
        dotImageTrailingConstraint.constant = message.read == true ? 0.0 : 6.0

        countLabelWidthConstraint.constant = countLabel.isHidden ? 0.0 : 28.0
        countLabelTrailingConstraint.constant = countLabel.isHidden ? 0.0 : 6.0
        
        let short = self.isShortNeed(message: message)
        leftlabelViewWidthConstraint.constant = short ? 45.0 : 85.0

        if leftlabelView.isHidden {
            leftlabelViewWidthConstraint.constant = 0.0
        }
        
        if rightlabelView.isHidden {
            rightlabelViewWidthConstraint.constant = 0.0
        }
        
        timerlabelsViewWidthConstraint.constant = leftlabelViewWidthConstraint.constant + rightlabelViewWidthConstraint.constant
        
        setupSenderLabelsAndBadgesView(short: short)
        
        self.layoutIfNeeded()
    }
}
