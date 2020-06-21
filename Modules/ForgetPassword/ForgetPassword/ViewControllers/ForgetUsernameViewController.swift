import UIKit
import Utility

class ForgetUsernameViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recoveryEmailTextField: UITextField! {
        didSet {
            recoveryEmailTextField.delegate = self
            recoveryEmailTextField.keyboardType = .emailAddress
        }
    }
    @IBOutlet weak var recoveryEmailPlaceholderLabel: UILabel!
    @IBOutlet weak var emailMyUserNameButton: UIButton!
    @IBOutlet weak var emailCheckerImageView: UIImageView!
    @IBOutlet weak var emailCheckerLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView! {
        didSet {
            loader.hidesWhenStopped = true
            loader.isHidden = true
        }
    }

    // MARK: Properties
    private weak var presenter: ForgetPasswordPresenter?

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

    // MARK: - UI
    private func initialUISetup() {
        title = Strings.ForgetPassword.forgotUserName.localized
        emailMyUserNameButton.setTitle(Strings.ForgetPassword.emailMyUserName.localized, for: .normal)
        titleLabel.text = Strings.ForgetPassword.enterYourEmailAddress.localized
        recoveryEmailPlaceholderLabel.text = Strings.Signup.recoveryEmailPlaceholder.localized

        defaultUIState()
    }
    
    private func defaultUIState() {
        toggleRecoverEmaildPlaceholder(false)
        
        emailCheckerImageView.image = nil
        emailCheckerLabel.text = ""
        
        presenter?.changeButtonState(button: emailMyUserNameButton, disabled: true)
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
        
        presenter?.changeButtonState(button: emailMyUserNameButton, disabled: state == false)
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
    
    @IBAction func onTapEmailMyUsername(_ sender: Any) {
        view.endEditing(true)
    }
}

// MARK: - UItextField Delegate
extension ForgetUsernameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            guard !updatedText.isEmpty else {
                defaultUIState()
                return true
            }
            
            toggleRecoverEmaildPlaceholder(true)
            
            // Replace previous task with a new one
            presenter?.validate(recoveryEmail: updatedText, in: self)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleRecoverEmaildPlaceholder(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        toggleRecoverEmaildPlaceholder(false)
    }
}

// MARK: - Loadable
extension ForgetUsernameViewController: Loadable {
    func onCompletionAPI() {
        
    }
    
    func startLoader() {
    }
    
    func stopLoader() {
    }
}
