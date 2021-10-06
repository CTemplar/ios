import UIKit
import Combine
import Utility

class AddAppContactsViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var deleteContactButton: UIButton!
    
    @IBOutlet weak var noteField: GrowingTextView!
    @IBOutlet weak var addressField: GrowingTextView!
    @IBOutlet weak var addressField_Height: NSLayoutConstraint!
    @IBOutlet weak var noteField_Height: NSLayoutConstraint!

    // MARK: Properties
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel: AddAppContactsViewModel!
    var onContactUpdateSuccess: (() -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = viewModel.navigationTitle

        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onTapSave))
        navigationItem.setRightBarButton(barButtonItem, animated: true)

        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Bindings & Observers
    private func setupBindings() {
        // Properties that can be assigned using default assign method
   
        subscriptions = [
            viewModel
                .$contactName
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [unowned self] (value) in
                    self.nameTextField.text = value
                }),
            
                //.assign(to: \.text, on: self.nameTextField),
            viewModel
                .$contactEmailAddress
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [unowned self] (value) in
                    self.emailAddressTextField.text = value
                }),
              //  .assign(to: \.text , on: self.emailAddressTextField),
            viewModel
                .$contactPhoneNumber
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [unowned self] (value) in
                    self.phoneNumberTextField.text = value
                }),
                //.assign(to: \.text, on: phoneNumberTextField),
            viewModel
                .$contactAddress
                .assign(to: \.text, on: addressField),
            viewModel
                .$contactNote
                .assign(to: \.text, on: noteField),
            viewModel
                .$hideDeleteContactOption
                .assign(to: \.isHidden, on: deleteContactButton),
            viewModel
                .$enableSaveOption
                .assign(to: \.isEnabled, on: navigationItem.rightBarButtonItem!),
            viewModel
                .onUpdateContact
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] (error) in
                   
                    switch error {
                    case .failure(let error):
                        let params = AlertKitParams(
                            title: Strings.AppError.error.localized,
                            message: error.localizedDescription,
                            cancelButton: Strings.Button.cancelButton.localized,
                            destructiveButtons: [Strings.Button.deleteButton.localized]
                        )
                        self?.showAlert(with: params, onCompletion: {})
                    case .finished: break
                    }
                    
                }, receiveValue: { [weak self] (_) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                        self?.onContactUpdateSuccess?()
                        self?.navigationController?.popViewController(animated: true)
                    }
                }),
            nameTextField
                .textPublisher
                .sink(receiveValue: { [unowned self] (value) in
                    self.viewModel.update(name: value)
                }),
            emailAddressTextField
                .textPublisher
                .sink(receiveValue: { [unowned self] (value) in
                    self.viewModel.update(email: value)
                }),
            phoneNumberTextField
                .textPublisher
                .sink(receiveValue: { [unowned self] (value) in
                    self.viewModel.update(phone: value)
                }),
            addressField
                .textPublisher
                .sink(receiveValue: { [unowned self] (value) in
                    self.viewModel.update(address: value)
                }),
            noteField
                .textPublisher
                .sink(receiveValue: { [unowned self] (value) in
                    self.viewModel.update(note: value)
                }),
        ]
        
    }

    // MARK: - Actions
    @objc
    private func onTapSave() {
        Loader.start()
        viewModel.saveContact()
    }
    
    @IBAction func onTapDelete(_ sender: UIButton) {
        let params = AlertKitParams(
            title: Strings.Inbox.Alert.deleteTitle.localized,
            message: Strings.Inbox.Alert.deleteContact.localized,
            cancelButton: Strings.Button.cancelButton.localized,
            destructiveButtons: [Strings.Button.deleteButton.localized]
        )
        
        showAlert(with: params, onCompletion: { [weak self] (index) in
            switch index {
            case 0: DPrint("Cancel Delete")
            default:
                DPrint("Delete")
                Loader.start()
                self?.viewModel.deleteContact()

            }
        })
    }
}
// MARK: - Binding
extension AddAppContactsViewController: Bindable {
    typealias ModelType = AddAppContactsViewModel
    
    func configure(with model: AddAppContactsViewModel) {
        self.viewModel = model
    }
}

extension AddAppContactsViewController : GrowingTextViewDelegate{
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        if textView == addressField{
            self.addressField_Height.constant = height
        }else{
            self.noteField_Height.constant = height
        }
    }
}
public extension UITextView {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextView.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextView } // receiving notifications with objects which are instances of UITextFields
            .map { $0.text ?? "" } // mapping UITextField to extract text
            .eraseToAnyPublisher()
    }
}
