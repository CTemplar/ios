//
//  AliasController.swift
//  AppSettings
//


import UIKit
import Utility
import Signup

class AliasController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var lastNameLbl:UILabel!
    @IBOutlet weak var addBtn:UIButton!
    // MARK: Properties
    private (set) var presenter: AliasPresenter?
    private var searchTask: DispatchWorkItem?
    @IBOutlet weak var userExistanceLabel: UILabel!
    @IBOutlet weak var userNameAndDomainLabel: UILabel!
    @IBOutlet weak var emailSubtitleLabel: UILabel!
    @IBOutlet weak var userExistanceImageView: UIImageView!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var loader: UIActivityIndicatorView! {
        didSet {
            loader.hidesWhenStopped = true
            loader.isHidden = true
        }
    }
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            backgroundImageView.image = #imageLiteral(resourceName: "LightBackground")
        }
    }
    
    @IBOutlet weak var userNamePlaceholderLabel: UILabel! {
        didSet {
            userNamePlaceholderLabel.text = Strings.Signup.usernamePlaceholder.localized
        }
    }
    @IBOutlet weak var userNameTxtField: UITextField! {
        didSet {
            userNameTxtField.delegate = self
            userNameTxtField.keyboardType = .alphabet
        }
    }
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.imageView?.tintColor = .black
            backButton.setImage(#imageLiteral(resourceName: "BackArrowDark").withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = AliasPresenter(parentController: self)
        // Do any additional setup after loading the view.
        initialUISetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = Strings.AppSettings.addresses.localized
        self.presenter?.setupTableView()
       // self.navigationController?.navigationBar.isHidden = true
    }

    @IBAction func btnAddTapped(_ sender: Any) {
        self.presenter?.interactor?.addBtnTapped()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UI
    private func initialUISetup() {
        addBtn.setTitle(Strings.Button.addButton.localized, for: .normal)
        userNameAndDomainLabel.text = Strings.Signup.usernameAndDomain.localized
        emailSubtitleLabel.text = Strings.Signup.ctemplarEmailAddress.localized
        
        if Device.IS_IPHONE {
            containerViewWidthConstraint.constant = UIScreen.main.bounds.size.width - (Device.IS_IPHONE_5 ? 40.0 : 20.0)
            view.layoutIfNeeded()
        }
        
        defaultUIState()
    }
    
    
    
     func defaultUIState() {
        if loader.isAnimating {
            loader.stopAnimating()
        }
        toggleUsernamePlaceholder(false)
        userExistanceImageView.image = nil
        userExistanceLabel.text = ""
      
       self.presenter?.changeButtonState(button: addBtn, disabled: true)
    }
    
    func update(by userExistance: UserExistance) {
        loader.stopAnimating()
        let image = userExistance.image.withRenderingMode(.alwaysTemplate)
        userExistanceImageView.image = image
        userExistanceImageView.tintColor = userExistance.color
        userExistanceLabel.text = userExistance.text
        userExistanceLabel.textColor = userExistance.color
        
        let state = (userExistance == .available && userNameTxtField.text?.isEmpty == false)
        self.presenter?.changeButtonState(button: addBtn, disabled: state == false)
    }
    
    private func toggleUsernamePlaceholder(_ shouldShow: Bool) {
        if shouldShow {
            userNamePlaceholderLabel.isHidden = false
            userNameTxtField.placeholder = ""
        } else {
            userNameTxtField.placeholder = Strings.Signup.usernamePlaceholder.localized
            userNamePlaceholderLabel.isHidden = true
        }
    }
}

// MARK: - UItextField Delegate
extension AliasController: UITextFieldDelegate {
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
                self?.presenter?.interactor?.checkUser(userName: updatedText)
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
