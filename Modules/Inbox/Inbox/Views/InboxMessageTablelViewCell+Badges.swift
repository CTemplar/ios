import Foundation
import UIKit
import Utility
import Networking

extension InboxMessageTableViewCell {
    func calculateBadgesViewWidth(short: Bool) -> CGFloat {
        let deleteLabelWidth = (rightlabelView.isHidden) ? 0.0 : (short ? 45.0 : 85.0)
        let leftLabelWidth = (leftlabelView.isHidden) ? 0.0 : (short ? 45.0 : 85.0)

        let labelsViewWidth = CGFloat(leftLabelWidth + deleteLabelWidth)
        
        var badgesViewWidth = dotImageWidthConstraint.constant  + dotImageTrailingConstraint.constant  + countLabelWidthConstraint.constant + countLabelTrailingConstraint.constant
        
        badgesViewWidth = badgesViewWidth + labelsViewWidth
        
        return badgesViewWidth
    }
}
