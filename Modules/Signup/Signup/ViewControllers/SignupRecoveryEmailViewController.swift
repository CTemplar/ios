import UIKit
import Utility

class SignupRecoveryEmailViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var logoImageView: UIImageView! {
        didSet {
            logoImageView.image = #imageLiteral(resourceName: "Logo")
        }
    }
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            if #available(iOS 12.0, *) {
                backButton.setImage(UIImage(named: "BackArrowDark", in: .main, compatibleWith: .init(userInterfaceStyle: .light)), for: .normal)
            } else {
                // Fallback on earlier versions
                backButton.setImage(#imageLiteral(resourceName: "BackArrowDark"), for: .normal)
            }
        }
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            backgroundImageView.image = #imageLiteral(resourceName: "LightBackground")
        }
    }
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var recoveryEmailPlaceholderLabel: UILabel!
    
    @IBOutlet weak var recoveryEmailTextField: UITextField! {
        didSet {
            recoveryEmailTextField.keyboardType = .emailAddress
            recoveryEmailTextField.delegate = self
        }
    }
    
    @IBOutlet weak var invitationCodeTextField: UITextField! {
        didSet {
            invitationCodeTextField.keyboardType = .default
            invitationCodeTextField.delegate = self
        }
    }
    
    @IBOutlet weak var invitationCodePlaceholderLabel: UILabel!
    
    @IBOutlet weak var recorveyEmailTitleLabel: UILabel!
    
    @IBOutlet weak var recorveyEmailSubtitleLabel: UILabel!
    
    @IBOutlet weak var supportMailTextView: UITextView!
    
    @IBOutlet weak var termsAndConditionTextView: UITextView!

    @IBOutlet weak var termsAndConditionButton: UIButton! {
        didSet {
            backButton.tintColor = recorveyEmailTitleLabel.textColor
            termsAndConditionButton.setImage(#imageLiteral(resourceName: "roundDark").withRenderingMode(.alwaysTemplate), for: .normal)
            termsAndConditionButton.setImage(#imageLiteral(resourceName: "selectedRoundDark").withRenderingMode(.alwaysTemplate), for: .selected)
            termsAndConditionButton.isSelected = false
        }
    }
    
    @IBOutlet weak var emailCheckerImageView: UIImageView!
    
    @IBOutlet weak var emailCheckerLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.isHidden = true
        }
    }
    
    // MARK: Properties
    private (set) var signupPageViewController: SignupPageViewController?

    // Add a emailTask property to your controller
    private var emailTask: DispatchWorkItem?
    
    private var emailChecker: EmailChecker = .incorrectEmail
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signupPageViewController = self.parent as? SignupPageViewController
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        view.addGestureRecognizer(freeSpaceViewGesture)

        initialUISetup()
        setupAttributesForTextView()
    }
    
    deinit {
        print("deinit called from \(self.className)")
    }
    
    // MARK: - UI
    private func initialUISetup() {
        nextButton.setTitle(Strings.Login.createAccount.localized, for: .normal)
        recorveyEmailTitleLabel.text = Strings.Signup.recoveryEmailAttr.localized
        recorveyEmailSubtitleLabel.text = Strings.Signup.thisIsUsed.localized
        supportMailTextView.text = Strings.Signup.supportEmailString.localized
        defaultUIState()
    }
    
    private func defaultUIState() {
        toggleRecoveryEmailPlaceholder(false)
        toggleInvitationCodePlaceholder(false)
        
        emailCheckerImageView.image = nil
        emailCheckerLabel.text = ""
        
        signupPageViewController?.presenter?.changeButtonState(button: nextButton, disabled: true)
    }
    
    private func toggleRecoveryEmailPlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            recoveryEmailPlaceholderLabel.isHidden = false
            recoveryEmailTextField.placeholder = ""
        } else {
            recoveryEmailTextField.placeholder = Strings.Signup.recoveryEmailAttr.localized
            recoveryEmailPlaceholderLabel.isHidden = true
        }
    }
    
    private func toggleInvitationCodePlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            invitationCodePlaceholderLabel.isHidden = false
            invitationCodeTextField.placeholder = ""
        } else {
            invitationCodeTextField.placeholder = Strings.Signup.invitationCodePlaceholder.localized
            invitationCodePlaceholderLabel.isHidden = true
        }
    }
    
    private func setupAttributesForTextView() {
        var attributedString: NSMutableAttributedString?
        
        if #available(iOS 12.0, *) {
            attributedString = NSMutableAttributedString(string: Strings.Signup.termsAndConditionsFullText.localized, attributes: [
                .font: AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)!,
                .foregroundColor: recorveyEmailTitleLabel.textColor!,
                .kern: 0.0
            ])
        } else {
            // Fallback on earlier versions
            attributedString = NSMutableAttributedString(string: Strings.Signup.termsAndConditionsFullText.localized, attributes: [
                .font: AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)!,
                .foregroundColor: k_lightGrayColor,
                .kern: 0.0
            ])
        }
                
        _ = attributedString?.setAsLink(textToFind: Strings.Signup.termsAndConditionsPhrase.localized, linkURL: GeneralConstant.Link.TermsURL.rawValue)
        _ = attributedString?.setForgroundColor(textToFind: Strings.Signup.termsAndConditionsPhrase.localized, color: k_urlColor)
        
        termsAndConditionTextView.attributedText = attributedString
        
        termsAndConditionTextView.disableTextPadding()
        termsAndConditionTextView.autosizeTextFont()
    }
    
    func update(by emailChecker: EmailChecker) {
        self.emailChecker = emailChecker
        
        let image = self.emailChecker.image.withRenderingMode(.alwaysTemplate)
        emailCheckerImageView.image = image
        emailCheckerImageView.tintColor = emailChecker.color
        emailCheckerLabel.text = emailChecker.text
        
        let state = (emailChecker == .correctEmail && recoveryEmailTextField.text?.isEmpty == false && termsAndConditionButton.isSelected == true)
        signupPageViewController?.presenter?.changeButtonState(button: nextButton, disabled: state == false)
    }
    
    func startLoader() {
        nextButton.setTitle("", for: .normal)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func stopLoader() {
        nextButton.setTitle(Strings.Login.createAccount.localized, for: .normal)
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    @IBAction func createAccount(_ sender: Any) {
        signupPageViewController?.presenter?.update(invitationCode: invitationCodeTextField.text ?? "")
        signupPageViewController?.presenter?.update(recoveryEmail: recoveryEmailTextField.text ?? "")
        signupPageViewController?.presenter?.createUserAccount()
        view.endEditing(true)
    }
    
    @IBAction func onTapBack(_ sender: Any) {
        signupPageViewController?.presenter?.showPrevious(of: self)
    }
    
    @IBAction func checkBoxButtonPressed(_ sender: AnyObject) {
        termsAndConditionButton.isSelected = true
        
        let state = (self.emailChecker == .correctEmail && recoveryEmailTextField.text?.isEmpty == false && termsAndConditionButton.isSelected == true)
        signupPageViewController?.presenter?.changeButtonState(button: nextButton, disabled: state == false)
    }
    
    @objc
    private func tappedViewAction(sender : UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

// MARK: - UItextField Delegate
extension SignupRecoveryEmailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            if textField == invitationCodeTextField {
                return true
            }
            
            // Cancel previous task if any
            self.emailTask?.cancel()
            

            guard !updatedText.isEmpty else {
                defaultUIState()
                return true
            }
            
            toggleRecoveryEmailPlaceholder(true)
            
            // Replace previous task with a new one
            let task = DispatchWorkItem { [weak self] in
                guard let safeSelf = self else { return }
                safeSelf.signupPageViewController?.presenter?.setupEmailNextButtonState(childViewController: safeSelf, sender: textField)
            }
            
            self.emailTask = task
            
            // Execute task in 0.75 seconds (if not cancelled !)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: task)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField == recoveryEmailTextField ? toggleRecoveryEmailPlaceholder(true) : toggleInvitationCodePlaceholder(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField == recoveryEmailTextField ? toggleRecoveryEmailPlaceholder(false) : toggleInvitationCodePlaceholder(false)
    }
}
