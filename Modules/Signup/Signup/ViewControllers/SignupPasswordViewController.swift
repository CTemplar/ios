import UIKit
import Utility

class SignupPasswordViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var logoImageView: UIImageView! {
        didSet {
            logoImageView.image = #imageLiteral(resourceName: "Logo")
        }
    }
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.setImage(#imageLiteral(resourceName: "BackArrowDark"), for: .normal)
        }
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            backgroundImageView.image = #imageLiteral(resourceName: "LightBackground")
        }
    }
    
    @IBOutlet weak var passwordTitleLabel: UILabel!
    
    @IBOutlet weak var passwordSubtitleLabel: UILabel!
    
    @IBOutlet weak var passwordPlaceholderLabel: UILabel!
    
    @IBOutlet weak var confirmPasswordPlaceholderLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var passwordEyeButton: UIButton! {
        didSet {
            passwordEyeButton.setImage(#imageLiteral(resourceName: "DarkEyeIcon"), for: .selected)
            passwordEyeButton.setImage(#imageLiteral(resourceName: "DarkEyeOnIcon"), for: .normal)
            passwordEyeButton.isSelected = false
        }
    }
    
    @IBOutlet weak var confirmPasswordEyeButton: UIButton! {
        didSet {
            confirmPasswordEyeButton.setImage(#imageLiteral(resourceName: "DarkEyeIcon"), for: .selected)
            confirmPasswordEyeButton.setImage(#imageLiteral(resourceName: "DarkEyeOnIcon"), for: .normal)
            confirmPasswordEyeButton.isSelected = false
        }
    }
    
    @IBOutlet weak var supportMailTextView: UITextView!
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.maxLength = maxPasswordLength
            passwordTextField.delegate = self
        }
    }
    
    @IBOutlet weak var confirmPasswordTextField: UITextField! {
        didSet {
            confirmPasswordTextField.maxLength = maxPasswordLength
            confirmPasswordTextField.delegate = self
        }
    }
    
    @IBOutlet weak var passwordCheckerImageView: UIImageView!
    
    @IBOutlet weak var passwordCheckerLabel: UILabel!
    
    // MARK: Properties
    private (set) var signupPageViewController: SignupPageViewController?
    
    // Add a passwordTask property to your controller
    private var passwordTask: DispatchWorkItem?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signupPageViewController = self.parent as? SignupPageViewController
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        view.addGestureRecognizer(freeSpaceViewGesture)

        initialUISetup()
    }
    
    // MARK: - UI
    private func initialUISetup() {
        nextButton.setTitle(Strings.Button.nextButton.localized, for: .normal)
        passwordTitleLabel.text = Strings.Signup.passwordPlaceholder.localized
        passwordSubtitleLabel.text = Strings.Signup.passwordMust.localized
        passwordPlaceholderLabel.text = Strings.Signup.choosePasswordPlaceholder.localized
        confirmPasswordPlaceholderLabel.text = Strings.Signup.confirmPasswordPlaceholder.localized
        supportMailTextView.text = Strings.Signup.supportEmailString.localized
        signupPageViewController?.presenter?.changePasswordEntryStyle(passwordEyeButton.isSelected == false, textField: passwordTextField)
        signupPageViewController?.presenter?.changePasswordEntryStyle(confirmPasswordEyeButton.isSelected == false, textField: confirmPasswordTextField)
        defaultUIState()
    }
    
    private func defaultUIState() {
        togglePasswordPlaceholder(false)
        toggleConfirmPasswordPlaceholder(false)
        
        passwordCheckerImageView.image = nil
        passwordCheckerLabel.text = ""
        
        signupPageViewController?.presenter?.changeButtonState(button: nextButton, disabled: true)
    }
    
    private func togglePasswordPlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            passwordPlaceholderLabel.isHidden = false
            passwordTextField.placeholder = ""
        } else {
            passwordTextField.placeholder = Strings.Signup.choosePasswordPlaceholder.localized
            passwordPlaceholderLabel.isHidden = true
        }
    }
    
    private func toggleConfirmPasswordPlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            confirmPasswordPlaceholderLabel.isHidden = false
            confirmPasswordTextField.placeholder = ""
        } else {
            confirmPasswordTextField.placeholder = Strings.Signup.confirmPasswordPlaceholder.localized
            confirmPasswordPlaceholderLabel.isHidden = true
        }
    }
    
    func update(by passwordChecker: PasswordChecker) {
        let image = passwordChecker.image.withRenderingMode(.alwaysTemplate)
        passwordCheckerImageView.image = image
        passwordCheckerImageView.tintColor = passwordChecker.color
        passwordCheckerLabel.text = passwordChecker.text
        
        let state = (passwordChecker == .matched && passwordTextField.text?.isEmpty == false && confirmPasswordTextField.text?.isEmpty == false)
        signupPageViewController?.presenter?.changeButtonState(button: nextButton, disabled: state == false)
    }
    
    // MARK: - Password Eye Handlers
    @IBAction func choosePasswordEyeButtonPressed(_ sender: Any) {
        passwordEyeButton.isSelected.toggle()
        signupPageViewController?.presenter?.changePasswordEntryStyle(passwordEyeButton.isSelected == false, textField: passwordTextField)
    }
    
    @IBAction func confirmPasswordEyeButtonPressed(_ sender: Any) {
        confirmPasswordEyeButton.isSelected.toggle()
        signupPageViewController?.presenter?.changePasswordEntryStyle(confirmPasswordEyeButton.isSelected == false, textField: confirmPasswordTextField)
    }
    
    // MARK: - Actions
    @IBAction func onTapBack(_ sender: Any) {
        signupPageViewController?.presenter?.showPrevious(of: self)
    }

    @IBAction func onTapNext(_ sender: Any) {
        signupPageViewController?.presenter?.update(password: passwordTextField.text ?? "")
        signupPageViewController?.presenter?.showNext(childViewController: self)
    }
    
    @objc
    private func tappedViewAction(sender : UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

// MARK: - UItextField Delegate
extension SignupPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            // Cancel previous task if any
            self.passwordTask?.cancel()
            
            guard !updatedText.isEmpty else {
                defaultUIState()
                return true
            }
            
            textField == passwordTextField ? togglePasswordPlaceholder(true) : toggleConfirmPasswordPlaceholder(true)
            
            // Replace previous task with a new one
            let task = DispatchWorkItem { [weak self] in
                guard let safeSelf = self else { return }
                safeSelf.signupPageViewController?.presenter?.setupPasswordsNextButtonState(childViewController: safeSelf, sender: textField)
            }
            self.passwordTask = task
            
            // Execute task in 0.75 seconds (if not cancelled !)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: task)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField == passwordTextField ? togglePasswordPlaceholder(true) : toggleConfirmPasswordPlaceholder(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField == passwordTextField ? togglePasswordPlaceholder(false) : toggleConfirmPasswordPlaceholder(false)
    }
}
