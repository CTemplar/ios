import UIKit
import Utility

class SignupViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var userExistanceImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var userExistanceLabel: UILabel!
    @IBOutlet weak var userNamePlaceholderLabel: UILabel! {
        didSet {
            userNamePlaceholderLabel.text = Strings.Signup.usernamePlaceholder.localized
        }
    }
    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.delegate = self
            usernameTextField.keyboardType = .alphabet
        }
    }
    @IBOutlet weak var userNameAndDomainLabel: UILabel!
    @IBOutlet weak var emailSubtitleLabel: UILabel!
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
    
    @IBOutlet weak var loader: UIActivityIndicatorView! {
        didSet {
            loader.hidesWhenStopped = true
            loader.isHidden = true
        }
    }
    
    // MARK: Properties
    private (set) var signupPageViewController: SignupPageViewController?
    // Add a searchTask property to your controller
    private var searchTask: DispatchWorkItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signupPageViewController = self.parent as? SignupPageViewController
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        view.addGestureRecognizer(freeSpaceViewGesture)
        
        initialUISetup()
    }
    
    deinit {
        print("deinit called from \(self.className)")
    }
    
    // MARK: - UI
    private func initialUISetup() {
        nextButton.setTitle(Strings.Button.nextButton.localized, for: .normal)
        userNameAndDomainLabel.text = Strings.Signup.usernameAndDomain.localized
        emailSubtitleLabel.text = Strings.Signup.ctemplarEmailAddress.localized
        
        defaultUIState()
    }
    
    private func defaultUIState() {
        if loader.isAnimating {
            loader.stopAnimating()
        }
        toggleUsernamePlaceholder(false)
        userExistanceImageView.image = nil
        userExistanceLabel.text = ""
        
        signupPageViewController?.presenter?.changeButtonState(button: nextButton, disabled: true)
    }
    
    func update(by userExistance: UserExistance) {
        loader.stopAnimating()
        let image = userExistance.image.withRenderingMode(.alwaysTemplate)
        userExistanceImageView.image = image
        userExistanceImageView.tintColor = userExistance.color
        userExistanceLabel.text = userExistance.text
        userExistanceLabel.textColor = userExistance.color
        
        let state = (userExistance == .available && usernameTextField.text?.isEmpty == false)
        signupPageViewController?.presenter?.changeButtonState(button: nextButton, disabled: state == false)
    }
    
    private func toggleUsernamePlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            userNamePlaceholderLabel.isHidden = false
            usernameTextField.placeholder = ""
        } else {
            usernameTextField.placeholder = Strings.Signup.usernamePlaceholder.localized
            userNamePlaceholderLabel.isHidden = true
        }
    }

    // MARK: - Actions
    @IBAction func onTapNext(_ sender: Any) {
        signupPageViewController?.presenter?.update(userName: usernameTextField.text ?? "")
        signupPageViewController?.presenter?.showNext(childViewController: self)
    }
    
    @IBAction func onTapBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func tappedViewAction(sender : UITapGestureRecognizer) {
        view.endEditing(true)
        if usernameTextField.text?.isEmpty == true {
            defaultUIState()
        }
    }
}
// MARK: - UItextField Delegate
extension SignupViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            // Cancel previous task if any
            self.searchTask?.cancel()
            
            guard !updatedText.isEmpty else {
                defaultUIState()
                return true
            }
            
            toggleUsernamePlaceholder(true)
            
            // Replace previous task with a new one
            let task = DispatchWorkItem { [weak self] in
                self?.loader.isHidden = false
                self?.loader.startAnimating()
                self?.signupPageViewController?.presenter?.interactor?.checkUser(userName: updatedText)
            }
            self.searchTask = task
            
            // Execute task in 0.75 seconds (if not cancelled !)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: task)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleUsernamePlaceholder(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        toggleUsernamePlaceholder(false)
    }
}
