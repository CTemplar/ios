import UIKit
import Utility
import IQKeyboardManagerSwift

class LoginViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var userNameTextField: UITextField! {
        didSet {
            userNameTextField.delegate = self
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    @IBOutlet weak var userNamePlaceholderLabel: UILabel!
    @IBOutlet weak var passwordPlaceholderLabel: UILabel!
    @IBOutlet weak var rememberMeLabel: UILabel!
    @IBOutlet weak var rememberMeButton: UIButton!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView! {
        didSet {
            logoImageView.image = #imageLiteral(resourceName: "Logo")
        }
    }

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.isHidden = true
        }
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            backgroundImageView.image = #imageLiteral(resourceName: "Background")
        }
    }
    
    // MARK: Properties
    private (set) var presenter: LoginPresenter?
    private (set) var router: LoginRouter?
    private (set) var configurator: LoginConfigurator?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !IQKeyboardManager.shared.enable {
            IQKeyboardManager.shared.enable = true
        }
        
        initialUISetup()
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(tappedViewAction(sender:)))
        view.addGestureRecognizer(freeSpaceViewGesture)
    }
    
    // MARK: - Setup
    func setup(presenter: LoginPresenter) {
        self.presenter = presenter
    }
    
    func setup(router: LoginRouter) {
        self.router = router
    }
    
    func setup(configurator: LoginConfigurator) {
        self.configurator = configurator
    }
    
    // MARK: - UI Updates
    private func initialUISetup() {
        signInButton.setTitle(Strings.Login.login.localized, for: .normal)
        signUpButton.setTitle(Strings.Login.createAccount.localized, for: .normal)

        passwordPlaceholderLabel.text = Strings.Login.password.localized
        userNamePlaceholderLabel.text = Strings.Signup.usernamePlaceholder.localized
        
        rememberMeLabel.text = Strings.Login.rememberMe.localized
        
        forgotPasswordButton.setTitle(Strings.Login.forgotPassword.localized, for: .normal)
        
        rememberMeButton.backgroundColor = .white
        rememberMeButton.setImage(RememberCredentialState.doNotRemember.stateImage(), for: .normal)
        rememberMeButton.setImage(RememberCredentialState.remember.stateImage(), for: .selected)
        rememberMeButton.isSelected = false
        
        eyeButton.setImage(#imageLiteral(resourceName: "EyeOnIcon"), for: .normal)
        eyeButton.setImage(#imageLiteral(resourceName: "EyeIcon"), for: .selected)
        eyeButton.isSelected = false
        
        defaultUIState()
    }
    
    private func defaultUIState() {
        toggleUsernamePlaceholder(false)
        togglePasswordPlaceholder(false)
        presenter?.changeButtonState(button: signInButton, disabled: true)
    }
    
    func update(by isValidated: Bool) {
        presenter?.changeButtonState(button: signInButton, disabled: isValidated == false)
    }
    
    private func toggleUsernamePlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            userNamePlaceholderLabel.isHidden = false
            userNameTextField.placeholder = ""
        } else {
            userNameTextField.placeholder = Strings.Signup.usernamePlaceholder.localized
            userNamePlaceholderLabel.isHidden = true
        }
    }
    
    private func togglePasswordPlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            passwordPlaceholderLabel.isHidden = false
            passwordTextField.placeholder = ""
        } else {
            passwordTextField.placeholder = Strings.Login.password.localized
            passwordPlaceholderLabel.isHidden = true
        }
    }
    
    // MARK: - Actions
    @objc
    private func tappedViewAction(sender : UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func onTapSignIn(_ sender: Any) {
        view.endEditing(true)
        presenter?.login()
    }
    
    @IBAction func onTapRememberMe(_ sender: UIButton) {
        sender.isSelected.toggle()
        configurator?.update(state: .getState(from: sender.isSelected))
    }
    
    @IBAction func onTapEye(_ sender: Any) {
        eyeButton.isSelected.toggle()
        presenter?.changePasswordEntryStyle(eyeButton.isSelected == false, textField: passwordTextField)
    }
    
    @IBAction func onTapForgetPassword(_ sender: Any) {
        router?.showForgotPasswordViewController()
    }
    
    @IBAction func onTapSignup(_ sender: Any) {
        router?.showSignUpViewController()
    }
    
    func startLoader() {
        signInButton.setTitle("", for: .normal)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func stopLoader() {
        signInButton.setTitle(Strings.Login.login.localized, for: .normal)
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}

// MARK: - UItextField Delegate
extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            textField == userNameTextField ? toggleUsernamePlaceholder(true) : togglePasswordPlaceholder(true)
            
            presenter?.validate(value: updatedText, of: textField)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField == userNameTextField ? toggleUsernamePlaceholder(true) : togglePasswordPlaceholder(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField == userNameTextField ? toggleUsernamePlaceholder(false) : togglePasswordPlaceholder(false)
    }
}
