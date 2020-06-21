import UIKit
import Utility

class ResetCodeViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var informationTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var resetCodePlaceholder: UILabel!
    @IBOutlet weak var resetCodeTextField: UITextField! {
        didSet {
            resetCodeTextField.delegate = self
            resetCodeTextField.keyboardType = .numberPad
        }
    }
    @IBOutlet weak var resetPasswordButton: UIButton!
    
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
        title = Strings.ForgetPassword.resetCodePlaceholder.localized
        titleLabel.text = Strings.Signup.enterIt.localized
        resetPasswordButton.setTitle(Strings.ForgetPassword.resetPassword.localized, for: .normal)
        resetCodePlaceholder.text = Strings.ForgetPassword.resetCodePlaceholder.localized
        
        setupAttributesForTextView()
        
        defaultUIState()
    }
    
    private func defaultUIState() {
        toggleResetCodePlaceholder(false)
        
        presenter?.changeButtonState(button: resetPasswordButton, disabled: true)
    }
    
    func setupAttributesForTextView() {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        var attributedString = NSMutableAttributedString(string: Strings.ForgetPassword.weHave.localized,
                                                         attributes: [
                                                            .font: AppStyle.CustomFontStyle.Regular.font(withSize: Device.IS_IPAD ? 20.0 : 14.0)!,
                                                            .foregroundColor: k_lightGrayColor,
                                                            .paragraphStyle: style,
                                                            .kern: 0.0
        ])
        
        if #available(iOS 13.0, *) {
            attributedString = NSMutableAttributedString(string: Strings.ForgetPassword.weHave.localized,
                                                             attributes: [
                                                                .font: AppStyle.CustomFontStyle.Regular.font(withSize:  Device.IS_IPAD ? 20.0 : 14.0)!,
                                                                .foregroundColor: k_lightGrayColor.resolvedColor(with: .init(userInterfaceStyle: .light)),
                                                                .paragraphStyle: style,
                                                                .kern: 0.0
            ])
        } else {
            // Fallback on earlier versions
        }
        
        _ = attributedString.setUnderline(textToFind: Strings.Signup.recoveryEmailAttr.localized)
        
        if #available(iOS 13.0, *) {
            _ = attributedString.setForgroundColor(textToFind: Strings.Signup.recoveryEmailAttr.localized,
                                                   color: k_urlColor.resolvedColor(with: .init(userInterfaceStyle: .light)))
        } else {
            // Fallback on earlier versions
            _ = attributedString.setForgroundColor(textToFind: Strings.Signup.recoveryEmailAttr.localized, color: k_urlColor)
        }

        
        informationTextView.attributedText = attributedString
        
        informationTextView.disableTextPadding()
        
        if (!Device.IS_IPAD) {
            informationTextView.autosizeTextFont()
        }
    }
    
    private func toggleResetCodePlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            resetCodePlaceholder.isHidden = false
            resetCodeTextField.placeholder = ""
        } else {
            resetCodeTextField.placeholder = Strings.ForgetPassword.resetCodePlaceholder.localized
            resetCodePlaceholder.isHidden = true
        }
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
        presenter?.showNewPasswordSetupScreen()
    }
}

// MARK: - UItextField Delegate
extension ResetCodeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            guard !updatedText.isEmpty else {
                defaultUIState()
                return true
            }
            
            toggleResetCodePlaceholder(true)
            
            // Replace previous task with a new one
            presenter?.validate(resetCode: updatedText, in: self)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleResetCodePlaceholder(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        toggleResetCodePlaceholder(false)
    }
}
