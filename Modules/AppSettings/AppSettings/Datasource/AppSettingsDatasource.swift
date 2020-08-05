import Foundation
import UIKit
import Utility
import Networking
import ObjectivePGP

final class AppSettingsDatasource: NSObject {
    // MARK: Properties
    private weak var tableView: UITableView?
    
    private weak var parentViewController: AppSettingsController?
    
    private var user = UserMyself()
    
    private var dataSource: [SettingsSection: [AppSettingsModel]] = [:]
    
    private let apiService = NetworkManager.shared.apiService
    
    private let formatterService = UtilityManager.shared.formatterService
    
    private let keychainService = UtilityManager.shared.keychainService
    
    private var recoveryEmailtextProtocol: NSObjectProtocol?
    
    private var oldPasswordTextProtocol: NSObjectProtocol?

    private var newPasswordTextProtocol: NSObjectProtocol?

    private var confirmPasswordTextProtocol: NSObjectProtocol?
    
    private var oldPassword: String?
    
    private var newPassword: String?
    
    private var confirmPassword: String?
    
    private var mailboxes: [Mailbox] = []
    
    private lazy var dispatchGroup: DispatchGroup = {
        return DispatchGroup()
    }()
    
    var appLanguage: String {
        var currentLanguage = ""
        let language = Bundle.getLanguage()
        switch language {
        case GeneralConstant.Language.english.prefix:
            currentLanguage = GeneralConstant.Language.english.name
        case GeneralConstant.Language.russian.prefix:
            currentLanguage = GeneralConstant.Language.russian.name
        case GeneralConstant.Language.french.prefix:
            currentLanguage = GeneralConstant.Language.french.name
        case GeneralConstant.Language.slovak.prefix:
            currentLanguage = GeneralConstant.Language.slovak.name
        default:
            currentLanguage = GeneralConstant.Language.english.name
        }
        return currentLanguage
    }
    
    // MARK: - Constructor
    init(tableView: UITableView, parentViewController: AppSettingsController?) {
        self.tableView = tableView
        self.parentViewController = parentViewController
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateDataSourceOnLanguageChange),
                                               name: .reloadViewControllerNotificationID, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDataUpdate),
                                               name: .updateUserDataNotificationID,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateMobileSignature),
                                               name: .reloadViewControllerDataSourceNotificationID,
                                               object: nil)
        setupTableView()
    }
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    func setup(user: UserMyself) {
        self.user = user
        
        // Download the latest mailbox in background
        fetchMailboxList()
        
        setupDataSource()
        tableView?.reloadData()
    }
    
    private func setupTableView() {
        tableView?.tableFooterView = UIView()
        
        tableView?.estimatedRowHeight = 60.0
        tableView?.rowHeight = UITableView.automaticDimension
        
        tableView?.delegate = self
        tableView?.dataSource = self
        
        tableView?.register(BaseAppSettingsCell.self, forCellReuseIdentifier: BaseAppSettingsCell.className)
        tableView?.register(AppSettingsStorageCell.self, forCellReuseIdentifier: AppSettingsStorageCell.className)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemBackground
        tableView?.backgroundView = backgroundView
    }
    
    private func setupDataSource() {
        dataSource.removeAll()
        SettingsSection.allCases.forEach({ initialiseModel(for: $0) })
    }
    
    private func initialiseModel(for section: SettingsSection) {
        let rows = section.rows
        var models: [AppSettingsModel] = []
        for row in rows {
            var model: AppSettingsModel?
            switch row {
            case .notifications:
                model = AppSettingsModel(title: Strings.AppSettings.notifications.localized)
            case .language:
                model = AppSettingsModel(title: Strings.AppSettings.language.localized,
                                         subtitle: appLanguage)
            case .contacts:
                let contactSavingEnabled = user.settings.saveContacts ?? false
                let subtitle = contactSavingEnabled ? Strings.AppSettings.enabled.localized : Strings.AppSettings.disabled.localized
                model = AppSettingsModel(title: Strings.AppSettings.savingContact.localized,
                                         subtitle: subtitle,
                                         showDetailIndicator: false)
            case .whiteOrBlackList:
                model = AppSettingsModel(title: Strings.AppSettings.whiteBlackList.localized)
            case .dashboard:
                model = AppSettingsModel(title: Strings.AppSettings.dashboard.localized)
            case .manageFolders:
                model = AppSettingsModel(title: Strings.AppSettings.manageFolders.localized)
            case .password:
                model = AppSettingsModel(title: Strings.AppSettings.password.localized,
                                         showDetailIndicator: false)
            case .recoveryEmail:
                model = AppSettingsModel(title: Strings.AppSettings.recoveryEmail.localized,
                                         subtitle: user.settings.recoveryEmail ?? "",
                                         showDetailIndicator: false)
            case .encryption:
                model = AppSettingsModel(title: Strings.AppSettings.manageSecurity.localized,
                                         showDetailIndicator: false)
            case .mail:
                if let mailbox = getDefaultMailBox(), mailbox.isDefault == true {
                    model = AppSettingsModel(title: mailbox.email ?? "",
                                             subtitle: Strings.AppSettings.defaultText.localized,
                                             showDetailIndicator: false)
                }
            case .signature:
                let signature = apiService.defaultMailbox(mailboxes: user.mailboxesList ?? []).signature ?? ""
                model = AppSettingsModel(title: Strings.AppSettings.signature.localized,
                                         subtitle: signature.isEmpty ? Strings.AppSettings.disabled.localized : Strings.AppSettings.enabled.localized,
                                         showDetailIndicator: false)
            case .mobileSignature:
                let signature = UserDefaults.standard.string(forKey: mobileSignatureKey) ?? ""
                model = AppSettingsModel(title: Strings.AppSettings.mobileSignature.localized,
                                         subtitle: signature.isEmpty ? Strings.AppSettings.disabled.localized : Strings.AppSettings.enabled.localized,
                                         showDetailIndicator: false)
            case .keys:
                model = AppSettingsModel(title: Strings.AppSettings.keys.localized)
            case .appVersion:
                if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    model = AppSettingsModel(title: "\(Strings.AppSettings.appVersion.localized) \(appVersion) (\(buildNumber))",
                        showDetailIndicator: false,
                        titleAlignment: .center,
                        titleColor: k_settingsCellSecondaryTextColor)
                }
            case .storage:
                if let usedStorage = user.settings.usedStorage, let allocatedStorage = user.settings.allocatedStorage {
                    let text = FormatterService.Units(bytes: Int64(usedStorage)).getReadableUnit() + " / " + FormatterService.Units(bytes: Int64(allocatedStorage)).getReadableUnit()
                    model = AppSettingsModel(title: text, showDetailIndicator: false, selectable: false, titleAlignment: .right)
                }
            case .logout:
                model = AppSettingsModel(title: Strings.AppSettings.logoutSettings.localized,
                                         showDetailIndicator: false,
                                         titleAlignment: .center,
                                         titleColor: AppStyle.Colors.loaderColor.color,
                                         titleFont: AppStyle.CustomFontStyle.Bold.font(withSize: 16.0)!)
            }
            
            if let model = model {
                models.append(model)
            }
        }
        
        dataSource[section] = models
    }
    
    private func getDefaultMailBox() -> Mailbox? {
        guard let mailboxes = user.mailboxesList else {
            return nil
        }
        
        return apiService.defaultMailbox(mailboxes: mailboxes)
    }

    func fetchMailboxList() {
        apiService.mailboxesList(completionHandler: { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let value):
                    if let mailboxes = value as? Mailboxes {
                        self?.mailboxes = mailboxes.mailboxesResultsList ?? []
                    }
                case .failure(let error):
                    DPrint(error.localizedDescription)
                }
            }
        })
    }
    
    // MARK: - Notitifcation Handler
    @objc
    private func updateDataSourceOnLanguageChange() {
        parentViewController?.setupNavigationBar()
        setupDataSource()
        tableView?.reloadData()
    }
    
    @objc func updateMobileSignature() {
        setupDataSource()
        tableView?.reloadData()
    }
    
    @objc
    private func userDataUpdate(notification: Notification) {
        guard let userData = notification.object as? UserMyself else {
            return
        }
        user = userData
        parentViewController?.setup(user: userData)
        setupDataSource()
        tableView?.reloadData()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension AppSettingsDatasource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard SettingsSection.allCases.count > section else {
            return 0
        }
        
        let section = SettingsSection.allCases[section]
        
        return dataSource[section]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard SettingsSection.allCases.count > indexPath.section else {
            return UITableViewCell()
        }
        
        let sectionType = SettingsSection.allCases[indexPath.section]
        
        if sectionType.rows.count > indexPath.row {
            let row = sectionType.rows[indexPath.row]
            
            switch row {
            case .notifications,
                 .language,
                 .contacts,
                 .whiteOrBlackList,
                 .dashboard,
                 .manageFolders,
                 .password,
                 .recoveryEmail,
                 .encryption,
                 .mail,
                 .signature,
                 .mobileSignature,
                 .keys,
                 .appVersion,
                 .logout:
                return configureBasicCell(at: indexPath, sectionType: sectionType)
            case .storage:
                return configureStorageCell(at: indexPath, sectionType: sectionType)
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard SettingsSection.allCases.count > section else {
            return nil
        }
        
        let sectionType = SettingsSection.allCases[section]
        
        return sectionType.name
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard SettingsSection.allCases.count > section else {
            return nil
        }
        
        let sectionType = SettingsSection.allCases[section]
        
        let headerView = UIView(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50.0))

        let label = UILabel()
        label.text = sectionType.name
        label.font = AppStyle.CustomFontStyle.Bold.font(withSize: 16.0)
        label.textColor = k_cellSubTitleTextColor
        label.backgroundColor = .clear
        headerView.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(16.0)
            make.centerY.equalToSuperview()
        }
        
        headerView.backgroundColor = k_borderColor
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard SettingsSection.allCases.count > indexPath.section else {
            return
        }
        
        let sectionType = SettingsSection.allCases[indexPath.section]
        
        if sectionType.rows.count > indexPath.row {
            let row = sectionType.rows[indexPath.row]
            
            switch row {
            case .notifications:
                parentViewController?.router?.onTapNotification()
            case .language:
                parentViewController?.router?.onTapLanguage()
            case .contacts:
                onTapSavingContacts()
            case .whiteOrBlackList:
                parentViewController?.router?.onTapWhiteBlackList()
            case .dashboard:
                parentViewController?.router?.onTapDashboard()
            case .manageFolders:
                parentViewController?.router?.onTapManageFolders()
            case .password:
                onTapChangePassword()
            case .recoveryEmail:
                onTapRecoveryMail()
            case .encryption:
                parentViewController?.router?.onTapEncryption()
            case .mail:
                let rect = tableView.rectForRow(at: indexPath)
                let rectInScreen = tableView.convert(rect, to: tableView.superview)
                onTapMail(with: rectInScreen)
            case .signature:
                parentViewController?.router?.onTapSignature(with: .general)
            case .mobileSignature:
                parentViewController?.router?.onTapSignature(with: .mobile)
            case .keys:
                parentViewController?.router?.onTapKeys()
            case .appVersion: break
            case .storage: break
            case .logout:
                parentViewController?.router?.onTapLogOut()
            }
        }
    }
    
    // MARK: - Cell Configuration
    private func configureBasicCell(at indexPath: IndexPath, sectionType: SettingsSection) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(withIdentifier: BaseAppSettingsCell.className,
                                                        for: indexPath) as? BaseAppSettingsCell,
            let models = dataSource[sectionType],
            models.count > indexPath.row else {
                return UITableViewCell()
        }
        
        let model = models[indexPath.row]
        cell.configure(with: model)
        
        return cell
    }
    
    private func configureStorageCell(at indexPath: IndexPath, sectionType: SettingsSection) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(withIdentifier: AppSettingsStorageCell.className,
                                                        for: indexPath) as? AppSettingsStorageCell,
            let models = dataSource[sectionType],
            models.count > indexPath.row else {
                return UITableViewCell()
        }
        
        let model = models[indexPath.row]
        cell.configure(with: model)
        
        return cell
    }
}
// MARK: - Save Contacts
private extension AppSettingsDatasource {
    func onTapSavingContacts() {
        let contactSavingEnabled = user.settings.saveContacts ?? false
        
        var alertText = Strings.AppSettings.saveContactsAlertTitle.localized
        alertText = alertText.replacingOccurrences(of: "%s", with: Bundle.main.displayName ?? "CTemplar")
        
        var alertMessage = Strings.AppSettings.saveContactsAlertMessage.localized
        alertMessage = alertMessage.replacingOccurrences(of: "%a",
                                                         with: contactSavingEnabled ?
                                                            Strings.AppSettings.enabled.localized: Strings.AppSettings.disabled.localized)
        
        let params = AlertKitParams(
            title: alertText,
            message: alertMessage,
            cancelButton: Strings.Button.cancelButton.localized,
            otherButtons: [
                Strings.Button.okButton.localized
            ]
        )
        
        parentViewController?.showAlert(with: params, onCompletion: { [weak self] (index) in
            switch index {
            case 0:
                DPrint("Canceled")
            default:
                DPrint("Changing Saving contact preferences")
                self?.changeSaveContactPreference(shouldEnable: !contactSavingEnabled)
            }
        })
    }
    
    func changeSaveContactPreference(shouldEnable: Bool) {
        Loader.start()
        let settingsID = user.settings.settingsID ?? 0
        apiService.updateSettings(settingsID: settingsID,
                                  recoveryEmail: "",
                                  dispalyName: "",
                                  savingContacts: shouldEnable,
                                  encryptContacts: user.settings.isContactsEncrypted ?? false,
                                  encryptAttachment: user.settings.isAttachmentsEncrypted ?? false,
                                  encryptSubject: user.settings.isSubjectEncrypted ?? false)
        { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop()
                switch(result) {
                case .success(let value):
                    print("updateSavingContacts value:", value)
                    NotificationCenter.default.post(name: .updateUserSettingsNotificationID, object: nil, userInfo: nil)
                    self?.tableView?.reloadSections(IndexSet(integer: 0), with: .automatic)
                case .failure(let error):
                    print("error:", error)
                    self?.parentViewController?.showAlert(with: Strings.AppError.error.localized,
                                                          message: error.localizedDescription,
                                                          buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }
}

// MARK: - Email Recovery
private extension AppSettingsDatasource {
    func onTapRecoveryMail() {
        let recoveryEmail = user.settings.recoveryEmail
        
        if recoveryEmail?.isEmpty == false {
            let alertTitle = Strings.AppSettings.recoveryEmail.localized
            let alertMessage = Strings.AppSettings.recoveryEmailEnabledAlertMessage.localized
            
            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            
            let updateAction = UIAlertAction(title: Strings.Button.updateButton.localized, style: .default) { [unowned self] (_) in
                guard let email = alertController.textFields?.first?.text
                    else { return }
                self.updateRecoveryEmail(email)
                self.recoveryEmailtextProtocol = nil
            }
            
            let disableAction = UIAlertAction(title: Strings.AppSettings.disable.localized,
                                              style: .destructive)
            { [unowned self] (_) in
                self.updateRecoveryEmail(" ")
            }
            
            let cancelAction = UIAlertAction(title: Strings.Button.cancelButton.localized, style: .cancel) { (_) in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addTextField { [unowned self] (textField) in
                textField.text = recoveryEmail
                self.recoveryEmailtextProtocol = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                                                         object: textField,
                                                                                         queue: OperationQueue.main)
                { (_) in
                    updateAction.isEnabled = self
                        .formatterService
                        .validateEmailFormat(enteredEmail: textField.text ?? "")
                }
            }
            
            alertController.addAction(updateAction)
            alertController.addAction(disableAction)
            alertController.addAction(cancelAction)
            
            parentViewController?.present(alertController, animated: true, completion: nil)
        } else {
            let alertTitle = Strings.AppSettings.recoveryEmail.localized
            let alertMessage = Strings.AppSettings.recoveryEmailDisabledAlertMessage.localized
            
            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

            let enableAction = UIAlertAction(title: Strings.AppSettings.enable.localized, style: .default) { [unowned self] (_) in
                guard let email = alertController.textFields?.first?.text
                    else { return }
                self.updateRecoveryEmail(email)
                self.recoveryEmailtextProtocol = nil
            }
            
            let cancelAction = UIAlertAction(title: Strings.Button.cancelButton.localized, style: .cancel) { (_) in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addTextField { [unowned self] (textField) in
                textField.text = recoveryEmail
                self.recoveryEmailtextProtocol = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                                                         object: textField,
                                                                                         queue: OperationQueue.main)
                { (_) in
                    enableAction.isEnabled = self
                        .formatterService
                        .validateEmailFormat(enteredEmail: textField.text ?? "")
                }
            }
            
            enableAction.isEnabled = false
            alertController.addAction(enableAction)
            alertController.addAction(cancelAction)
            
            parentViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func updateRecoveryEmail(_ email: String) {
        let settingsID = user.settings.settingsID ?? 0
        let savingContacts = user.settings.saveContacts
        
        Loader.start(presenter: parentViewController)
        apiService.updateSettings(settingsID: settingsID, recoveryEmail: email, dispalyName: "", savingContacts: savingContacts ?? false, encryptContacts: user.settings.isContactsEncrypted ?? false, encryptAttachment: user.settings.isAttachmentsEncrypted ?? false, encryptSubject: user.settings.isSubjectEncrypted ?? false) { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop(in: self?.parentViewController)
                switch(result) {
                case .success:
                    self?.recoveryEmailUpdated()
                case .failure(let error):
                    self?.parentViewController?.showAlert(with: Strings.AppError.error.localized,
                                                          message: error.localizedDescription,
                                                          buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }
    
    func recoveryEmailUpdated() {
        let params = AlertKitParams(
            title: Strings.AppSettings.infoTitle.localized,
            message: Strings.AppSettings.recoveryEmailUpdatedMessage.localized,
            cancelButton: Strings.Button.closeButton.localized
        )
        
        parentViewController?.showAlert(with: params, onCompletion: {
            NotificationCenter.default.post(name: .updateUserSettingsNotificationID, object: nil, userInfo: nil)
        })
    }
}

// MARK: - Default Mail change
private extension AppSettingsDatasource {

    func onTapMail(with rect: CGRect) {
        let userMailboxes = user.mailboxesList ?? []
        
        let controller = UIAlertController(title: "\(Strings.AppSettings.mailSettings.localized) \(Strings.AppSettings.addresses.localized)",
            message: nil,
            preferredStyle: .actionSheet)
        
        userMailboxes.forEach({ (mailBox) in
            let title = mailBox.isDefault == true ? "\(mailBox.email ?? "") ✔︎" : mailBox.email ?? ""
            let action = UIAlertAction(title: title, style: .default) { [unowned self] (_) in
                self.updateDefaultMail(mailBox)
                controller.dismiss(animated: true, completion: nil)
            }
            controller.addAction(action)
        })
        
        let cancelAction = UIAlertAction(title: Strings.Button.cancelButton.localized, style: .cancel) { (_) in
            controller.dismiss(animated: true, completion: nil)
        }
        
        controller.addAction(cancelAction)
        
        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceRect = rect
            popoverController.sourceView = parentViewController?.view
        }
        
        parentViewController?.present(controller, animated: true, completion: nil)
    }
    
    func updateDefaultMail(_ mailbox: Mailbox) {
        let mailboxID = mailbox.mailboxID?.description
        let isDefault = true
        
        Loader.start(presenter: parentViewController)
        
        apiService.updateMailbox(mailboxID: mailboxID!,
                                 userSignature: "",
                                 displayName: "",
                                 isDefault: isDefault)
        { [weak self] (result) in
            DispatchQueue.main.async {
                Loader.stop(in: self?.parentViewController)
                switch(result) {
                case .success:
                    NotificationCenter.default.post(name: .updateUserSettingsNotificationID, object: nil, userInfo: nil)
                case .failure(let error):
                    self?.parentViewController?.showAlert(with: Strings.AppError.error.localized,
                                                          message: error.localizedDescription,
                                                          buttonTitle: Strings.Button.closeButton.localized)
                }
            }
        }
    }
}

// MARK: - Change Password
extension AppSettingsDatasource: HashingService {
    func onTapChangePassword() {
        let alertController = UIAlertController(title: Strings.AppSettings.goToWebVersion.localized,
                                                message: Strings.AppSettings.changePasswordNotAvailableMessage.localized,
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: Strings.Button.closeButton.localized,
                                   style: .default, handler: nil)
        alertController.addAction(action)
        parentViewController?.present(alertController, animated: true, completion: nil)
        
        return
        
        func commonEyeButton(onTap: @escaping ((Bool) -> Void)) -> UIButton {
            let button = UIButton(type: .system)
            button.tintColor = k_mailboxTextColor
            button.setImage(UIImage(systemName: "eye"), for: .normal)
            button.setImage(UIImage(systemName: "eye.slash"), for: .selected)
            button.isSelected = false
            button.actionHandler(controlEvents: .touchUpInside) {
                onTap(button.isSelected)
            }
            return button
        }
        
        let alert = UIAlertController(title: Strings.AppSettings.changePasswordTitle.localized,
                                      message: Strings.AppSettings.changePasswordMessage.localized,
                                      preferredStyle: .alert)
        
        let changePasswordWithKeepDataAction = UIAlertAction(title: Strings.AppSettings.updateAndKeepData.localized,
                                                 style: .default)
        { [unowned self] (_) in
            self.oldPasswordTextProtocol = nil
            self.newPasswordTextProtocol = nil
            self.confirmPasswordTextProtocol = nil
            self.changePassword(deleteData: false)
        }
        
        let changePasswordWithDeleteDataAction = UIAlertAction(title: Strings.AppSettings.updateAndDeleteData.localized,
                                                 style: .default)
        { [unowned self] (_) in
            self.oldPasswordTextProtocol = nil
            self.newPasswordTextProtocol = nil
            self.confirmPasswordTextProtocol = nil
            self.changePassword(deleteData: true)
        }
        
        let cancelAction = UIAlertAction(title: Strings.Button.cancelButton.localized, style: .cancel) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        // Old Password Field
        alert.addTextField { [unowned self] (textField) in
            textField.placeholder = Strings.AppSettings.currentPasswordPlaceholder.localized
            textField.isSecureTextEntry = true
            textField.rightView = commonEyeButton(onTap: { (isSelected) in
                textField.isSecureTextEntry = isSelected ? false : true
            })
            self.oldPasswordTextProtocol = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                                                     object: textField,
                                                                                     queue: OperationQueue.main)
            { (_) in
                self.oldPassword = textField.text
                let shouldEnable = self.textDidChangeInPasswordChangeAlert()
                changePasswordWithKeepDataAction.isEnabled = shouldEnable
                changePasswordWithDeleteDataAction.isEnabled = shouldEnable
            }
        }
        
        // New Password Field
        alert.addTextField { [unowned self] (textField) in
            textField.placeholder = Strings.AppSettings.newPasswordPlaceholder.localized
            textField.isSecureTextEntry = true
            textField.rightView = commonEyeButton(onTap: { (isSelected) in
                textField.isSecureTextEntry = isSelected ? false : true
            })
            self.newPasswordTextProtocol = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                                                     object: textField,
                                                                                     queue: OperationQueue.main)
            { (_) in
                self.newPassword = textField.text
                let shouldEnable = self.textDidChangeInPasswordChangeAlert()
                changePasswordWithKeepDataAction.isEnabled = shouldEnable
                changePasswordWithDeleteDataAction.isEnabled = shouldEnable
            }
        }
        
        // Confirm Password Field
        alert.addTextField { [unowned self] (textField) in
            textField.placeholder = Strings.Signup.confirmPasswordPlaceholder.localized
            textField.isSecureTextEntry = true
            textField.rightView = commonEyeButton(onTap: { (isSelected) in
                textField.isSecureTextEntry = isSelected ? false : true
            })
            self.confirmPasswordTextProtocol = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                                                     object: textField,
                                                                                     queue: OperationQueue.main)
            { (_) in
                self.confirmPassword = textField.text
                let shouldEnable = self.textDidChangeInPasswordChangeAlert()
                changePasswordWithKeepDataAction.isEnabled = shouldEnable
                changePasswordWithDeleteDataAction.isEnabled = shouldEnable
            }
        }
        
        changePasswordWithKeepDataAction.isEnabled = false
        changePasswordWithDeleteDataAction.isEnabled = false
        
        alert.addAction(changePasswordWithKeepDataAction)
        alert.addAction(changePasswordWithDeleteDataAction)
        alert.addAction(cancelAction)
        
        parentViewController?.present(alert, animated: true, completion: nil)
    }
    
    func changePassword(deleteData: Bool) {
        Loader.start()
        retrieveChangePasswordDetails(deleteData: deleteData) { [weak self] (detail) in
            guard let details = try? detail.get() else {
                DispatchQueue.main.async {
                    Loader.stop()
                    self?.parentViewController?.showAlert(with: Strings.AppError.error.localized,
                                                          message: Strings.AppError.hashingFailure.localized,
                                                          buttonTitle: Strings.Button.closeButton.localized)
                }
                return
            }
            
            NetworkManager.shared.networkService.changePassword(with: details) { [weak self] (result) in
                DispatchQueue.main.async {
                    Loader.stop()
                    switch result {
                    case .success(let value):
                        DPrint("changePassword value:", value)
                        self?.keychainService.saveUserCredentials(userName: details.username,
                                                                  password: self?.newPassword ?? "")
                        self?.passwordWasUpdated()
                    case .failure(let error):
                        self?.oldPassword = nil
                        self?.newPassword = nil
                        self?.confirmPassword = nil
                        self?.parentViewController?.showAlert(with: Strings.AppError.error.localized,
                                                              message: error.localizedDescription,
                                                              buttonTitle: Strings.Button.closeButton.localized)
                    }
                }
            }
        }
    }
    
    func retrieveChangePasswordDetails(deleteData: Bool, with completion: @escaping Completion<ChangePasswordDetails>) {
        let error = {
            completion(.failure(AppError.cryptoFailed))
        }
        DispatchQueue.global().async {
            let userName = UtilityManager.shared.keychainService.getUserName()
            
            if userName.isEmpty {
                DispatchQueue.main.async(execute: error)
                return
            }
            
            let old = UtilityManager.shared.keychainService.getPassword()
            
            if old.isEmpty {
                DispatchQueue.main.async(execute: error)
                return
            }

            var keys: [[String: Any]] = []

            self.generateMailboxKeys(username: userName,
                                     oldPassword: old,
                                     password: self.newPassword ?? "",
                                     resetKeys: deleteData,
                                     list: self.mailboxes) { (keyList) in
                                        keys = keyList
            }
            
            guard !keys.isEmpty else {
                DispatchQueue.main.async(execute: error)
                return
            }
            
            var oldHashedPassword: String?
            var newHashedPassword: String?
            
            self.dispatchGroup.enter()
            
            self.generateHashedPassword(for: userName, password: self.oldPassword ?? "") { [weak self] in
                oldHashedPassword = try? $0.get()
                self?.dispatchGroup.leave()
            }
            
            self.dispatchGroup.wait()
            
            self.dispatchGroup.enter()
            
            self.generateHashedPassword(for: userName, password: self.newPassword ?? "") { [weak self] in
                newHashedPassword = try? $0.get()
                self?.dispatchGroup.leave()
            }
            
            self.dispatchGroup.wait()
            
            guard let oldHashed = oldHashedPassword,
                let newHashed = newHashedPassword else {
                    DispatchQueue.main.async(execute: error)
                    return
            }
            
            let details = ChangePasswordDetails(username: userName,
                                                oldHashedPassword: oldHashed,
                                                newHashedPassword: newHashed,
                                                newKeys: keys,
                                                deleteData: deleteData)
            DispatchQueue.main.async {
                completion(.success(details))
            }
        }
    }
    
    func passwordWasUpdated() {
        let params = AlertKitParams(
            title: Strings.AppSettings.infoTitle.localized,
            message: Strings.AppSettings.passwordUpdatedMessage.localized,
            cancelButton: Strings.Button.closeButton.localized
        )
        
        parentViewController?.showAlert(with: params, onCompletion: { [weak self] (_) in
            self?.parentViewController?.router?.logoutAction()
        })
    }
    
    func generateMailboxKeys(username: String,
                             oldPassword: String,
                             password: String,
                             resetKeys: Bool,
                             list: [Mailbox]?,
                             onCompletion: @escaping (([[String: Any]]) -> Void)) {
        var keys: [[String: Any]] = []
        
        if resetKeys {
            let mailboxList = list ?? []
            dispatchGroup.enter()
            
            for (index, mailBox) in mailboxList.enumerated() {
                generateCryptoInfo(for: username, password: password) { [weak self] in
                    guard let info = try? $0.get() else {
                        self?.dispatchGroup.leave()
                        return
                    }
                    
                    keys.append(
                        [
                            "mailbox_id": mailBox.mailboxID?.description ?? "",
                            "private_key": info.userPgpKey.privateKey,
                            "public_key": info.userPgpKey.publicKey,
                            "fingerprint": info.userPgpKey.fingerprint
                        ]
                    )
                    
                    if index == mailboxList.count - 1 {
                        onCompletion(keys)
                        self?.dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.wait()
        } else {
            let keyList = list?.compactMap({ (mailBox) -> [String: Any]? in
                return [
                    "mailbox_id": mailBox.mailboxID?.description ?? "",
                    "private_key": mailBox.privateKey ?? "",
                    "public_key": mailBox.publicKey ?? "",
                    "fingerprint": mailBox.fingerprint ?? ""
                ]
            }) ?? []
            onCompletion(keyList)
        }
    }
}

private extension AppSettingsDatasource {
    func isValidPassword(_ password: String) -> Bool {
        return UtilityManager.shared.formatterService.validatePasswordLench(enteredPassword: password) && UtilityManager.shared.formatterService.validatePasswordFormat(enteredPassword: password)
    }

    func textDidChangeInPasswordChangeAlert() -> Bool {
        guard let old = oldPassword,
            let new = newPassword,
            let confirmed = confirmPassword else {
            return false
        }
        return isValidPassword(old) && isValidPassword(new) && new == confirmed
    }
}

extension UIButton {
    private func actionHandler(action: (() -> Void)? = nil) {
        struct __ { static var action: (() -> Void)? }
        if action != nil { __.action = action }
        else { __.action?() }
    }
    
    @objc private func triggerActionHandler() {
        self.actionHandler()
    }
    
    func actionHandler(controlEvents control: UIControl.Event, ForAction action: @escaping () -> Void) {
        self.actionHandler(action: action)
        self.addTarget(self, action: #selector(triggerActionHandler), for: control)
    }
}
