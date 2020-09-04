import Foundation
import UIKit
import Utility
import SnapKit
import Networking
import Combine

final class ComposeMailOtherEmailCell: UITableViewCell, Cellable {
    
    // MARK: Properties
    @IBOutlet weak var emailIdTokenView: KSTokenView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet var tokenTrailingConstraintToView: NSLayoutConstraint!
    
    @IBOutlet var tokenTrailingConstraintToButton: NSLayoutConstraint!
    
    private (set) var model: ComposeMailOtherEmailModel!
    
    private let formatter = UtilityManager.shared.formatterService

    var onTapMore: (() -> Void)?
    
    var height: CGFloat {
        guard let contentHeight = emailIdTokenView.contentSize else {
            return 50.0
        }
        
        return contentHeight > 50.0 ? contentHeight : 50.0
    }
    
    private var anyCancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        emailIdTokenView.backgroundColor = .clear
    }
    
    deinit {
        anyCancellables.forEach({ $0.cancel() })
        anyCancellables.removeAll()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        emailIdTokenView.deleteAllTokens()
    }

    private func setup(shouldAddButton: Bool) {
        // Do any additional setup after loading the view.
        backgroundColor = .systemBackground
        
        selectionStyle = .none
        
        emailIdTokenView.supreViewRect = tableView?.rectForRow(at: model.indexPath)
        emailIdTokenView.direction = .vertical
        emailIdTokenView.tokenizingCharacters = [",", " "]
        emailIdTokenView.maximumHeight = 120.0
        emailIdTokenView.maxTokenLimit = -1
        emailIdTokenView.placeholder = Strings.WhiteBlackListContact.email.localized
        emailIdTokenView.placeholderColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray.withAlphaComponent(0.5) : UIColor.systemGray.withAlphaComponent(0.2)
        emailIdTokenView.style = .squared
        emailIdTokenView.minimumCharactersToSearch = 1
        emailIdTokenView.activityIndicatorColor = k_redColor
        emailIdTokenView.paddingY = 0.0
        emailIdTokenView.cursorColor = .label
        emailIdTokenView.shouldHideSearchResultsOnSelect = true
        emailIdTokenView.font = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)!
        emailIdTokenView.delegate = self
        emailIdTokenView.promptText = model.mode.localized
        emailIdTokenView.promptColor = UIColor.systemGray.withAlphaComponent(0.7)
        emailIdTokenView.descriptionText = "\(Strings.AppSettings.mailSettings.localized) \(Strings.AppSettings.addresses.localized)"
        emailIdTokenView.backgroundColor = .clear

        addButton.tintColor = k_cellTitleTextColor
        addButton.setImage(#imageLiteral(resourceName: "downArrow"), for: .normal)
        addButton.contentHorizontalAlignment = .right

        if model.mode == .to {
            tokenTrailingConstraintToButton.isActive = true
            tokenTrailingConstraintToView.isActive = false
            addButton.isHidden = false
            addButton.setImage(SenderPrefixMode.to.chevronImage, for: .normal)
            addButton.setImage(UIImage(systemName: "minus.circle"), for: .selected)
            addButton.addTarget(self, action: #selector(onTapMore(_:)), for: .touchUpInside)
            addButton.isSelected = false
        } else {
            tokenTrailingConstraintToButton.isActive = false
            tokenTrailingConstraintToView.isActive = true
            addButton.isHidden = true
            addButton.setImage(nil, for: .normal)
            addButton.setImage(nil, for: .selected)
            addButton.removeTarget(nil, action: nil, for: .allEvents)
        }
    }
    
    // MARK: - Actions
    @objc
    private func onTapMore(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        onTapMore?()
    }
    
    // MARK: - Configuration
    func configure(with model: Modelable) {
        guard let model = model as? ComposeMailOtherEmailModel else {
            fatalError("Couldn't type cast ComposeMailEmailModel")
        }
        
        self.model = model
        
        setup(shouldAddButton: self.model?.mode == .to)

        // Add Observer
        self.model
            .$collapsed
            .map({ $0 })
            .sink(receiveValue: { [weak self] in
                self?.addButton.isSelected = $0 == false
            })
            .store(in: &anyCancellables)
        
        for value in model.mailIds {
            let token = KSToken(title: value)
            token.tokenBackgroundColor = k_redColor
            token.maxWidth = 300.0
            token.tokenBackgroundHighlightedColor = .systemRed
            emailIdTokenView.addToken(token)
        }
                
        layoutIfNeeded()
    }
}

extension ComposeMailOtherEmailCell: KSTokenViewDelegate {
    func tokenView(_ tokenView: KSTokenView,
                   performSearchWithString string: String, completion: ((_ results: Array<AnyObject>) -> Void)?) {
        
        if string.isEmpty {
            completion?(model.contacts as Array<AnyObject>)
            return
        }
        
        var data: Array<String> = []
        
        for value: Contact in model.contacts {
            if let contactName = value.contactName,
                contactName.lowercased().range(of: string.lowercased()) != nil,
                let emailId = value.email, UtilityManager.shared.formatterService.validateEmailFormat(enteredEmail: emailId) {
                data.append(emailId)
            }
        }

        completion?(data as Array<AnyObject>)
    }
    
    func tokenView(_ tokenView: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as? String ?? ""
    }
    
    func tokenView(_ tokenView: KSTokenView, shouldAddToken token: KSToken) -> Bool {
        token.maxWidth = 300.0
        token.tokenBackgroundColor = k_redColor
        token.tokenBackgroundHighlightedColor = .systemRed
        return true
    }
    
    func tokenView(_ tokenView: KSTokenView, didAddToken token: KSToken) {
        updateToken(token, shouldAdd: true)
    }
    
    func tokenView(_ tokenView: KSTokenView, didDeleteToken token: KSToken) {
        updateToken(token, shouldAdd: false)
    }
    
    func tokenViewDidBeginEditing(_ tokenView: KSTokenView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.model.height = self.height
            self.updateTableViewLayout()
        }
    }
    
    func tokenViewDidEndEditing(_ tokenView: KSTokenView) {
        model.height = 50.0
        updateTableViewLayout()
    }
    
    private func updateToken(_ token: KSToken, shouldAdd: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            if UtilityManager.shared.formatterService.validateEmailFormat(enteredEmail: token.title) {
                self.model.subject.send((token.title, shouldAdd))
                DispatchQueue.main.async {
                    self.model.height = self.height
                    self.updateTableViewLayout()
                }
            }
        }
    }
    
    private func updateTableViewLayout() {
        self.tableView?.beginUpdates()
        self.tableView?.endUpdates()
    }
}
