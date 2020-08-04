import UIKit
import Utility
import Networking
import IQKeyboardManagerSwift

class SignatureViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var signatureToggleSwitch: UISwitch!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var signatureEditorView: RichEditorView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: Properties
    lazy private var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        toolbar.tintColor = AppStyle.Colors.loaderColor.color
        return toolbar
    }()
    private let apiService = NetworkManager.shared.apiService
    private let formatterService = UtilityManager.shared.formatterService
    private var user = UserMyself()
    private var signatureType = SignatureType.general
    private var mailbox = Mailbox()
    private var userSignature = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !IQKeyboardManager.shared.enable {
            IQKeyboardManager.shared.enable = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDefaultMailbox()
        setupScreen()
        setupMessageEditorView()
        signatureEditorView.delegate = self
    }
    
    // MARK: - Setup
    func setup(signatureType: SignatureType) {
        self.signatureType = signatureType
    }
    
    func setup(user: UserMyself) {
        self.user = user
    }
    
    private func setDefaultMailbox() {
        mailbox = apiService.defaultMailbox(mailboxes: user.mailboxesList ?? [])
    }
    
    private func setupMessageEditorView() {
        textFieldView.borderWidth = 1.0
        textFieldView.borderColor = k_borderColor

        signatureEditorView.tintColor = AppStyle.Colors.loaderColor.color
        signatureEditorView.inputAccessoryView = toolbar
        signatureEditorView.placeholder = Strings.AppSettings.typeMessage.localized
        signatureEditorView.setTextColor(.label)
        
        toolbar.editor = self.signatureEditorView
        toolbar.delegate = self
        
        let clearItem = RichEditorOptionItem(image: nil, title: Strings.AppSettings.clear.localized) { (toolbar) in
            toolbar.editor?.html = ""
        }
        
        let doneItem = RichEditorOptionItem(image: nil, title: Strings.AppSettings.done.localized) { (toolbar) in
            self.signatureEditorView.endEditing(true)
        }
        
        var options = toolbar.options
        options.append(contentsOf: [clearItem, doneItem])
        toolbar.options = options
    }
    
    private func setupScreen() {
        title = signatureType == .general ? Strings.AppSettings.signature.localized : Strings.AppSettings.mobileSignature.localized
       
        titleLabel.text = Strings.AppSettings.enableSignature.localized
        
        let value = signatureType == .general ?
            mailbox.signature :
            UserDefaults.standard.string(forKey: mobileSignatureKey)
        
        if let signature = value {
            if !signature.isEmpty {
                userSignature = signature
                textFieldView.isHidden = false
                signatureEditorView.html = signature
                signatureToggleSwitch.setOn(true, animated: true)
                setupRightNavigationItem(shouldShow: true)
            } else {
                textFieldView.isHidden = true
                signatureToggleSwitch.setOn(false, animated: true)
                setupRightNavigationItem(shouldShow: false)
            }
        } else {
            self.textFieldView.isHidden = true
            signatureToggleSwitch.setOn(false, animated: true)
            setupRightNavigationItem(shouldShow: false)
        }
    }
    
    private func setupRightNavigationItem(shouldShow: Bool) {
        if shouldShow {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                target: self,
                                                                action: #selector(onTapSave(_:)))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - Actions
    @objc
    private func onTapSave(_ sender: Any) {
        Loader.start(presenter: self)
        guard signatureType == .mobile else {
            self.updateUserSignature(mailbox: self.mailbox, userSignature: self.userSignature)
            return
        }
        UserDefaults.standard.set(userSignature, forKey: mobileSignatureKey)
        postUpdateUserSettingsNotification()
        userSignatureWasUpdated()
    }
    
    private func rigthBarButtonEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = formatterService.validateNameLench(enteredName: userSignature)
    }
    
    @IBAction func switchStateDidChange(_ sender: UISwitch) {
        if sender.isOn {
            textFieldView.isHidden = false
            userSignature = self.signatureEditorView.html
            setupRightNavigationItem(shouldShow: true)
            rigthBarButtonEnabled()
            textFieldView.becomeFirstResponder()
        } else {
            textFieldView.isHidden = true
            let value = signatureType == .general ? mailbox.signature : UserDefaults.standard.string(forKey: mobileSignatureKey)
            if let signature = value {
                if !signature.isEmpty {
                    userSignature = signatureType == .general ? " " : "" //api doesn't update signature if to send empty "" string
                } else {
                    setupRightNavigationItem(shouldShow: false)
                }
            }
        }
    }
    
    // MARK: - Signature Update
    private func updateUserSignature(mailbox: Mailbox, userSignature: String) {
        let mailboxID = mailbox.mailboxID?.description ?? ""
        let isDefault = mailbox.isDefault ?? false
        
        apiService.updateMailbox(mailboxID: mailboxID,
                                 userSignature: userSignature,
                                 displayName: "",
                                 isDefault: isDefault) { [weak self] (result) in
                                    DispatchQueue.main.async {
                                        Loader.stop(in: self)
                                        switch(result) {
                                        case .success:
                                            self?.postUpdateUserSettingsNotification()
                                            self?.userSignatureWasUpdated()
                                        case .failure(let error):
                                            self?.showAlert(with: Strings.AppError.error.localized,
                                                            message: error.localizedDescription,
                                                            buttonTitle: Strings.Button.closeButton.localized)
                                        }
                                    }
        }
    }
    
    private func postUpdateUserSettingsNotification() {
        let name: Notification.Name = signatureType == .general ? .updateUserSettingsNotificationID : .reloadViewControllerDataSourceNotificationID
        NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
    }
    
    private func userSignatureWasUpdated() {
        let params = AlertKitParams(
            title: Strings.AppSettings.infoTitle.localized,
            message: Strings.AppSettings.userSignature.localized,
            cancelButton: Strings.Button.closeButton.localized
        )
        showAlert(with: params) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - RichEditorDelegate
extension SignatureViewController: RichEditorDelegate {
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        userSignature = content
        rigthBarButtonEnabled()
    }
}

// MARK: - RichEditorToolbarDelegate
extension SignatureViewController: RichEditorToolbarDelegate {
    private func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple,
            .black,
            .darkGray,
            .brown
        ]
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }
    
    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }
    
    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.hasRangeSelection(handler: { (isRangedSelection) in
            if isRangedSelection {
                let alert = UIAlertController(title: Strings.AppSettings.insertLink.localized,
                                              message: nil, preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = Strings.AppSettings.urlRequired.localized
                }
                alert.addTextField { (textField) in
                    textField.placeholder = Strings.AppSettings.title.localized
                }
                alert.addAction(UIAlertAction(title: Strings.AppSettings.insert.localized, style: .default, handler: { (action) in
                    let textField1 = alert.textFields![0]
                    let textField2 = alert.textFields![1]
                    let url = textField1.text ?? ""
                    if url == "" {
                        return
                    }
                    let title = textField2.text ?? ""
                    toolbar.editor?.insertLink(href: url, text: title)
                }))
                alert.addAction(UIAlertAction(title: Strings.Button.cancelButton.localized, style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {}
}
