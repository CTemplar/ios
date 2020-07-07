import Foundation
import UIKit
import Utility

class UpgradeToPrimeView: UIView {

    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var notNowLabel: UILabel!
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.addGestureRecognizer(freeSpaceViewGesture)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.text = Strings.AppUpgrade.upgrade.localized
        
        self.upgradeButton.setTitle(Strings.AppUpgrade.upgradeBig.localized, for: .normal)
        
        self.notNowLabel.text = Strings.AppUpgrade.notNow.localized
    }
    
    //MARK: - IBActions
    
    @IBAction func upgradeAction(_ sender: AnyObject) {
        
        if let url = URL(string: GeneralConstant.Link.UpgradeURL.rawValue) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
 
        self.isHidden = true
    }
}
