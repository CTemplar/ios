import UIKit
import Utility

class ConfirmResetPasswordViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var informationTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
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
        initialUISetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    // MARK: - UI
    private func initialUISetup() {
        title = Strings.ForgetPassword.confirmResetPassword.localized
        titleLabel.text = Strings.ForgetPassword.areYouSure.localized
        confirmButton.setTitle(Strings.Button.confirmButton.localized, for: .normal)
        setupAttributesForTextView()
    }
    
    func setupAttributesForTextView() {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        var attributedString = NSMutableAttributedString(string: Strings.ForgetPassword.supportDescription.localized,
                                                         attributes: [
                                                            .font: AppStyle.CustomFontStyle.Regular.font(withSize: Device.IS_IPAD ? 20.0 : 14.0)!,
                                                            .foregroundColor: k_lightGrayColor,
                                                            .paragraphStyle: style,
                                                            .kern: 0.0
        ])
        
        if #available(iOS 13.0, *) {
            attributedString = NSMutableAttributedString(string: Strings.ForgetPassword.supportDescription.localized,
                                                         attributes: [
                                                            .font: AppStyle.CustomFontStyle.Regular.font(withSize: Device.IS_IPAD ? 20.0 : 14.0)!,
                                                            .foregroundColor: k_lightGrayColor.resolvedColor(with: .init(userInterfaceStyle: .light)),
                                                            .paragraphStyle: style,
                                                            .kern: 0.0
            ])
        } else {
            // Fallback on earlier versions
        }
        
        _ = attributedString.setUnderline(textToFind: "support@ctemplar.com")
        
        if #available(iOS 13.0, *) {
            _ = attributedString.setForgroundColor(textToFind: Strings.ForgetPassword.supportDescriptionAttr.localized,
                                                   color: k_redColor.resolvedColor(with: .init(userInterfaceStyle: .light)))
            _ = attributedString.setForgroundColor(textToFind: "support@ctemplar.com",
                                                   color: k_urlColor.resolvedColor(with: .init(userInterfaceStyle: .light)))
        } else {
            // Fallback on earlier versions
            _ = attributedString.setForgroundColor(textToFind: Strings.ForgetPassword.supportDescriptionAttr.localized,
                                                   color: k_redColor)
            _ = attributedString.setForgroundColor(textToFind: "support@ctemplar.com",
                                                   color: k_urlColor)
        }
        
        informationTextView.attributedText = attributedString
        
        informationTextView.disableTextPadding()
        informationTextView.autosizeTextFont()
    }
    
    // MARK: - Setup
    func setup(presenter: ForgetPasswordPresenter?) {
        self.presenter = presenter
    }
    
    // MARK: - Actions
    @IBAction func onTapConfirm(_ sender: Any) {
        presenter?.sendResetCode()
    }
}
// MARK: - Loadable
extension ConfirmResetPasswordViewController: Loadable {
    func startLoader() {
        confirmButton.setTitle("", for: .normal)
        loader.isHidden = false
        loader.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func stopLoader() {
        confirmButton.setTitle(Strings.Button.confirmButton.localized, for: .normal)
        loader.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    func onCompletionAPI() {
        presenter?.showResetCodeScreen()
    }
}
