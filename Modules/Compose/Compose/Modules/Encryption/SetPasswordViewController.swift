import UIKit
import Utility
import Combine

class SetPasswordViewController: UIViewController, UITextFieldDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.text = Strings.Scheduler.encryptForNon.localized
        }
    }
    
    @IBOutlet weak var setPasswordTextField: UITextField! {
        didSet {
            setPasswordTextField.delegate = self
            setPasswordTextField.placeholder = Strings.Scheduler.messagePassword.localized
        }
    }
    
    @IBOutlet weak var confirmPasswordTextField: UITextField! {
        didSet {
            confirmPasswordTextField.delegate = self
            confirmPasswordTextField.placeholder = Strings.Signup.confirmPasswordPlaceholder.localized
        }
    }
    
    @IBOutlet weak var hintPasswordTextField: UITextField! {
        didSet {
            hintPasswordTextField.delegate = self
            hintPasswordTextField.placeholder = Strings.Scheduler.passwordHint.localized
        }
    }
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var applyBarButtonItem: UIBarButtonItem! {
        didSet {
            applyBarButtonItem.isEnabled = false
        }
    }
    
    @IBOutlet weak var daysTextField: UITextField! {
        didSet {
            daysTextField.keyboardType = .numberPad
            daysTextField.delegate = self
        }
    }
    
    @IBOutlet weak var hoursTextField: UITextField! {
        didSet {
            hoursTextField.keyboardType = .numberPad
            hoursTextField.delegate = self
        }
    }
    
    @IBOutlet weak var redLineView: UIView! {
        didSet {
            redLineView.backgroundColor = k_encryptSeperatorColor
        }
    }
    
    @IBOutlet weak var passWarningLabel: UILabel!

    // MARK: Properties
    private var anyCancellables = Set<AnyCancellable>()
    
    private let viewModel = SetPasswordViewModel()
    
    var onCompletion: ((String, String, Int) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        daysTextField.text = "5"
        hoursTextField.text = "0"

        // Add Observers
        setupObservers()
        
        navigationBar.topItem?.title = Strings.Scheduler.setPassword.localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setPasswordTextField.becomeFirstResponder()
    }
    
    deinit {
        anyCancellables.forEach({ $0.cancel() })
        anyCancellables.removeAll()
    }
    
    // MARK: - Setup
    private func setupObservers() {
        anyCancellables = [
            daysTextField
                .textPublisher
                .assign(to: \.days, on: viewModel),
            
            hoursTextField
                .textPublisher
                .assign(to: \.hours, on: viewModel),
            
            setPasswordTextField
                .textPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.password, on: viewModel),
            
            confirmPasswordTextField
                .textPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.confirmPassword, on: viewModel),
            
            hintPasswordTextField
                .textPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.passwordHint, on: viewModel),
            
            viewModel
                .validatedPassword
                .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.passWarningLabel.isHidden = $0
                self?.redLineView.backgroundColor = $0 ? k_encryptSeperatorColor : k_redColor
                self?.applyBarButtonItem.isEnabled = $0
            })
        ]
    }

    // MARK: - Actions
    @IBAction func applyButtonPressed(_ sender: Any) {
        if let overallHours = viewModel.expirationTime() {
            dismiss(animated: true) { [weak self] in
                self?.onCompletion?(self?.viewModel.password ?? "",
                                    self?.viewModel.passwordHint ?? "",
                                    overallHours)
            }
        } else {
            showExpirationTimeAlert()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    // MARK: - Helpers
    private func showExpirationTimeAlert() {
        showAlert(with: Strings.AppSettings.infoTitle.localized,
                  message: Strings.Scheduler.expirationTime.localized,
                  buttonTitle: Strings.Button.closeButton.localized)
    }
}
