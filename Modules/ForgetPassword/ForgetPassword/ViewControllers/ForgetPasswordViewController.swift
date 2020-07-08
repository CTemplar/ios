import UIKit
import Utility
import IQKeyboardManagerSwift

class ForgetPasswordViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.delegate = self
        }
    }
    @IBOutlet weak var recoveryEmailTextField: UITextField! {
        didSet {
            recoveryEmailTextField.delegate = self
            recoveryEmailTextField.keyboardType = .emailAddress
        }
    }
    @IBOutlet weak var usernamePlaceholderLabel: UILabel!
    @IBOutlet weak var recoveryEmailPlaceholderLabel: UILabel!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var forgotUsernameButton: UIButton!
    
    @IBOutlet weak var emailCheckerImageView: UIImageView!
    @IBOutlet weak var emailCheckerLabel: UILabel!

    // MARK: Properties
    private (set) var presenter: ForgetPasswordPresenter?
    private var textFieldTask: DispatchWorkItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !IQKeyboardManager.shared.enable {
            IQKeyboardManager.shared.enable = true
        }
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        view.addGestureRecognizer(freeSpaceViewGesture)
        
        initialUISetup()
    }
    
    // MARK: - UI
    private func initialUISetup() {
        title = Strings.Login.forgotPassword.localized.replacingOccurrences(of: "?", with: "")
        resetPasswordButton.setTitle(Strings.ForgetPassword.resetPassword.localized, for: .normal)
        titleLabel.text = Strings.ForgetPassword.resetLink.localized
        recoveryEmailPlaceholderLabel.text = Strings.Signup.recoveryEmailPlaceholder.localized
        usernamePlaceholderLabel.text = Strings.Signup.usernamePlaceholder.localized
        forgotUsernameButton.setTitle(Strings.ForgetPassword.forgotUserName.localized, for: .normal)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.Button.closeButton.localized, style: .done, target: self, action: #selector(onTapClose))

        defaultUIState()
    }
    
    private func defaultUIState() {
        toggleUsernamePlaceholder(false)
        toggleRecoverEmaildPlaceholder(false)
        
        emailCheckerImageView.image = nil
        emailCheckerLabel.text = ""
        
        presenter?.changeButtonState(button: resetPasswordButton, disabled: true)
    }
    
    private func toggleUsernamePlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            usernamePlaceholderLabel.isHidden = false
            usernameTextField.placeholder = ""
        } else {
            usernameTextField.placeholder = Strings.Signup.usernamePlaceholder.localized
            usernamePlaceholderLabel.isHidden = true
        }
    }
    
    private func toggleRecoverEmaildPlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            recoveryEmailPlaceholderLabel.isHidden = false
            recoveryEmailTextField.placeholder = ""
        } else {
            recoveryEmailTextField.placeholder = Strings.Signup.recoveryEmailPlaceholder.localized
            recoveryEmailPlaceholderLabel.isHidden = true
        }
    }
    
    func update(by emailChecker: EmailChecker) {
        // Match/Unmatch check
        let image = emailChecker.image.withRenderingMode(.alwaysTemplate)
        emailCheckerImageView.image = image
        emailCheckerImageView.tintColor = emailChecker.color
        emailCheckerLabel.text = emailChecker.text
                
        let state = emailChecker == .correctEmail
        
        presenter?.changeButtonState(button: resetPasswordButton, disabled: state == false)
    }
    
    // MARK: - Setup
    func setup(presenter: ForgetPasswordPresenter?) {
        self.presenter = presenter
    }
    
    // MARK: - Actions
    @objc
    private func tappedViewAction(sender : UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func onTapResetPassword(_ sender: Any) {
        view.endEditing(true)
        presenter?.showConfirmResetPasswordScreen()
    }
    
    @IBAction func onTapForgotUserName(_ sender: Any) {
        view.endEditing(true)
        presenter?.showForgetUserNameScreen()
    }
    
    @objc
    private func onTapClose() {
        presenter?.backToLogin()
    }
}

// MARK: - UItextField Delegate
extension ForgetPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            // Cancel previous task if any
            textFieldTask?.cancel()
            
            guard !updatedText.isEmpty else {
                defaultUIState()
                return true
            }
            
            textField == usernameTextField ? toggleUsernamePlaceholder(true) : toggleRecoverEmaildPlaceholder(true)
            
            // Replace previous task with a new one
            let task = DispatchWorkItem { [weak self] in
                guard let safeSelf = self else { return }
                if textField == safeSelf.usernameTextField {
                    safeSelf.presenter?.validate(userName: updatedText, in: safeSelf)
                } else {
                    safeSelf.presenter?.validate(recoveryEmail: updatedText, in: safeSelf)
                }
            }
            
            textFieldTask = task
            
            // Execute task in 0.75 seconds (if not cancelled !)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: task)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField == usernameTextField ? toggleUsernamePlaceholder(true) : toggleRecoverEmaildPlaceholder(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField == usernameTextField ? toggleUsernamePlaceholder(false) : toggleRecoverEmaildPlaceholder(false)
    }
}
