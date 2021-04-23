import Foundation
import UIKit
import Utility
import Networking

final class EncryptionDatasource: NSObject {
    // MARK: Properties
    private (set) weak var tableView: UITableView?
    private (set) weak var parentController: EncryptionController?
    private var items: [Encryption] = []
    private var user = UserMyself()
    
    // MARK: - Constructor
    init(tableView: UITableView, parentController: EncryptionController?) {
        self.tableView = tableView
        self.parentController = parentController
        super.init()
        
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView?.estimatedRowHeight = 60.0
        tableView?.estimatedSectionFooterHeight = 60.0
        tableView?.allowsSelection = false
        tableView?.tableFooterView = UIView()
        tableView?.contentInsetAdjustmentBehavior = .never
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(EncryptionCell.self, forCellReuseIdentifier: EncryptionCell.className)
        
        parentController?.edgesForExtendedLayout = []
    }
    
    func setupDataSource() {
        items.removeAll()
        
        let currentPlan = user.settings.planType ?? ""
        let pendingPayment = user.settings.isPendingPayment ?? true
        let isFreePlan = (currentPlan.lowercased() != "free" && pendingPayment == false) ? false : true
        
     /*   let subjectEncryption = Encryption(title: Strings.AppSettings.subjectEncryption.localized,
                                           isOn: user.settings.isSubjectEncrypted ?? false,
                                           isEnabled: isFreePlan == false,
                                           type: .subject)
        let attachmentEncryption = Encryption(title: Strings.AppSettings.attachmentEncryption.localized,
                                              isOn: user.settings.isAttachmentsEncrypted ?? false,
                                              isEnabled: isFreePlan == false,
                                              type: .attachment)
        items.append(subjectEncryption)
        items.append(attachmentEncryption) */
        
        let contactEncryption = Encryption(title: Strings.AppSettings.сontactsEncryption.localized,
                                           isOn: user.settings.isContactsEncrypted ?? false,
                                           isEnabled: isFreePlan == false,
                                           type: .contacts)
        
        items.append(contactEncryption)
        
        
        if isFreePlan {
            let subtitle = PaddingLabel()
            subtitle.topInset = 10.0
            subtitle.bottomInset = 10.0
            subtitle.leftInset = 10.0
            subtitle.rightInset = 10.0
            
            subtitle.font = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)
            subtitle.textColor = k_cellSubTitleTextColor.withAlphaComponent(0.5)
            subtitle.textAlignment = .center
            subtitle.numberOfLines = 2
            subtitle.lineBreakMode = .byWordWrapping
            subtitle.text = Strings.AppSettings.encryptionDisabled.localized
            tableView?.tableFooterView = subtitle
        }
        
        tableView?.reloadData()
    }
    
    func setup(user: UserMyself) {
        self.user = user
    }
    
    func adjustFooterViewHeightToFillTableView() {
        guard let table = tableView, let tableFooterView = table.tableFooterView else { return }

        let minHeight = tableFooterView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let currentFooterHeight = tableFooterView.frame.height
        let safeAreaBottomHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        let fitHeight = table.frame.height - table.adjustedContentInset.top - table.contentSize.height + currentFooterHeight - safeAreaBottomHeight
        let nextHeight = (fitHeight > minHeight) ? fitHeight : minHeight

        // No height change needed ?
        guard round(nextHeight) != round(currentFooterHeight) else { return }

        var frame = tableFooterView.frame
        frame.size.height = nextHeight
        tableFooterView.frame = frame
        table.tableFooterView = tableFooterView
    }
}
// MARK: - UITableViewDelegate, UITableViewDatasource
extension EncryptionDatasource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EncryptionCell.className,
                                                       for: indexPath) as? EncryptionCell else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        cell.configure(with: item)
        cell.onChangeValue = { [weak self] (isOn) in
            self?.toggleEncryptionOrDecryption(of: item, switchIsOn: isOn, cell: cell)
        }
        return cell
    }
    
    // MARK: - Encryption/Decryption
    func toggleEncryptionOrDecryption(of item: Encryption, switchIsOn: Bool, cell: EncryptionCell) {
        
        var item = item
        
        let encryptSubject = item.type == .subject ? switchIsOn : user.settings.isSubjectEncrypted ?? false
        let encryptContact = item.type == .contacts ? switchIsOn : user.settings.isContactsEncrypted ?? false
        let encryptAttachment = item.type == .attachment ? switchIsOn : user.settings.isAttachmentsEncrypted ?? false
        
        func encryptOrDecrypt() {
            parentController?.interactor?.encryptOrDecryptItem(withSettings: user.settings,
                                                               encryptionType: item.type,
                                                               encryptSubject: encryptSubject,
                                                               encryptContacts: encryptContact,
                                                               encryptAttachment: encryptAttachment,
                                                               onCompletion:
                { [weak self] (error) in
                    if error == nil {
                        cell.activityIndicatorView.stopAnimating()
                        NotificationCenter.default.post(name: .updateUserSettingsNotificationID, object: nil, userInfo: nil)
                        item.update(state: switchIsOn)
                        self?.parentController?
                            .view
                            .makeToast(switchIsOn ? item.type.encryptedlocalized : item.type.decryptedlocalized)
                    } else {
                        cell.revert()
                    }
            })
        }

        if item.type == .contacts {
            let alertTitle = switchIsOn ? Strings.EncryptionDecryption.encryptContactsTitle.localized : Strings.EncryptionDecryption.decryptContactsTitle.localized
            let alertMessage = switchIsOn ? Strings.EncryptionDecryption.encryptContacts.localized : Strings.EncryptionDecryption.decryptContacts.localized
            
            let params = AlertKitParams(
                title: alertTitle,
                message: alertMessage,
                cancelButton: Strings.Button.cancelButton.localized,
                otherButtons: [switchIsOn ? Strings.Button.encryptButton.localized: Strings.Button.decryptButton.localized]
            )
            
            parentController?.showAlert(with: params, onCompletion: { (index) in
                switch index {
                case 0:
                    cell.revert()
                default:
                    cell.activityIndicatorView.isHidden = false
                    cell.activityIndicatorView.startAnimating()
                    encryptOrDecrypt()
                }
            })
            
        } else {
            cell.activityIndicatorView.isHidden = false
            cell.activityIndicatorView.startAnimating()
            encryptOrDecrypt()
        }
    }
}
