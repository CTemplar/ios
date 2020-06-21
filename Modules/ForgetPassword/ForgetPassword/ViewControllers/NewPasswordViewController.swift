import UIKit
import Utility
import Signup

final class NewPasswordViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newPasswordPlaceholder: UILabel!
    @IBOutlet weak var newPasswordTextField: UITextField! {
        didSet {
            newPasswordTextField.maxLength = maxPasswordLength
            newPasswordTextField.isSecureTextEntry = true
            newPasswordTextField.delegate = self
        }
    }
    @IBOutlet weak var confirmPasswordPlaceholder: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField! {
        didSet {
            confirmPasswordTextField.maxLength = maxPasswordLength
            confirmPasswordTextField.isSecureTextEntry = true
            confirmPasswordTextField.delegate = self
        }
    }
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView! {
        didSet {
            loader.hidesWhenStopped = true
            loader.isHidden = true
        }
    }
    @IBOutlet weak var passwordCheckerImageView: UIImageView!
    @IBOutlet weak var passwordCheckerLabel: UILabel!
    
    // MARK: Properties
    private (set) var presenter: ForgetPasswordPresenter?
    private var passwordTask: DispatchWorkItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        view.addGestureRecognizer(freeSpaceViewGesture)
        
        initialUISetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    // MARK: - Setup
    func setup(presenter: ForgetPasswordPresenter?) {
        self.presenter = presenter
    }

    // MARK: - UI
    private func initialUISetup() {
        title = Strings.Login.forgotPassword.localized.replacingOccurrences(of: "?", with: "")
        resetPasswordButton.setTitle(Strings.ForgetPassword.resetPassword.localized, for: .normal)
        titleLabel.text = Strings.ForgetPassword.forgetPass.localized
        newPasswordPlaceholder.text = Strings.ForgetPassword.newPasswordPlaceholder.localized
        confirmPasswordPlaceholder.text = Strings.ForgetPassword.confirmNewPasswordPlaceholder.localized
        
        defaultUIState()
    }
    
    private func defaultUIState() {
        togglePasswordPlaceholder(false)
        toggleConfirmPasswordPlaceholder(false)
        
        passwordCheckerImageView.image = nil
        passwordCheckerLabel.text = ""
        
        presenter?.changeButtonState(button: resetPasswordButton, disabled: true)
    }
    
    private func togglePasswordPlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            newPasswordPlaceholder.isHidden = false
            newPasswordTextField.placeholder = ""
        } else {
            newPasswordTextField.placeholder = Strings.ForgetPassword.confirmNewPasswordPlaceholder.localized
            newPasswordPlaceholder.isHidden = true
        }
    }
    
    private func toggleConfirmPasswordPlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            confirmPasswordPlaceholder.isHidden = false
            confirmPasswordTextField.placeholder = ""
        } else {
            confirmPasswordTextField.placeholder = Strings.ForgetPassword.newPasswordPlaceholder.localized
            confirmPasswordPlaceholder.isHidden = true
        }
    }
    
    func update(by passwordChecker: PasswordChecker) {
        // Match/Unmatch check
        let image = passwordChecker.image.withRenderingMode(.alwaysTemplate)
        passwordCheckerImageView.image = image
        passwordCheckerImageView.tintColor = passwordChecker.color
        passwordCheckerLabel.text = passwordChecker.text
                
        let state = passwordChecker == .matched
        
        presenter?.changeButtonState(button: resetPasswordButton, disabled: state == false)
    }
    
    // MARK: - Actions
    @IBAction func onTapResetPassword(_ sender: Any) {
        view.endEditing(true)
        presenter?.resetPassword()
    }
    
    @objc
    private func tappedViewAction(sender : UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

// MARK: - UItextField Delegate
extension NewPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            // Cancel previous task if any
            passwordTask?.cancel()
            
            guard !updatedText.isEmpty else {
                defaultUIState()
                return true
            }
            
            textField == newPasswordTextField ? togglePasswordPlaceholder(true) : toggleConfirmPasswordPlaceholder(true)
            
            // Replace previous task with a new one
            let task = DispatchWorkItem { [weak self] in
                guard let safeSelf = self else { return }
                safeSelf.presenter?.setupPasswordsNextButtonState(childViewController: safeSelf, sender: textField)
            }
            
            passwordTask = task
            
            // Execute task in 0.75 seconds (if not cancelled !)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: task)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField == newPasswordTextField ? togglePasswordPlaceholder(true) : toggleConfirmPasswordPlaceholder(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField == newPasswordTextField ? togglePasswordPlaceholder(false) : toggleConfirmPasswordPlaceholder(false)
    }
}

// MARK: - Loadable
extension NewPasswordViewController: Loadable {
    func onCompletionAPI() {
        let params = AlertKitParams(
            title: Strings.ForgetPassword.passwordResetSuccessTitle.localized,
            message: Strings.ForgetPassword.passwordResetSuccessMessage.localized,
            cancelButton: Strings.Button.okButton.localized
        )
        showAlert(with: params) { [weak self] in
            self?.presenter?.showInbox()
        }
    }
    
    func startLoader() {
        resetPasswordButton.setTitle("", for: .normal)
        loader.isHidden = false
        loader.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func stopLoader() {
        resetPasswordButton.setTitle(Strings.ForgetPassword.resetPassword.localized, for: .normal)
        loader.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}
