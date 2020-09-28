import UIKit
import Utility
import Combine
import Networking
import MobileCoreServices
import InboxViewer

final class ComposeController: UITableViewController, EmptyStateMachine  {
    
    // MARK: Properties
    private (set) var viewModel: ComposeViewModel!
    
    private (set) var router: ComposeRouter!
    
    private var bindables = Set<AnyCancellable>()
    
    var toCellId: String {
        "ToCellIdentifier"
    }
    
    var ccCellId: String {
        "CcCellIdentifier"
    }
    
    var bccellId: String {
        "BccCellIdentifier"
    }
    
    private var onPickupDocumentFromPicker: ((URL) -> Void)?
    
    private let documentInteractionController = UIDocumentInteractionController()
        
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        router = ComposeRouter(parentViewController: self)
        
        documentInteractionController.delegate = self

        extendedLayoutIncludesOpaqueBars = true
        
        edgesForExtendedLayout = []
        
        setupTableView()
        
        setupNavigationItem()
        
        setupVM()

        setupObservers()
        
        NotificationCenter.default.post(name: .disableIQKeyboardManagerNotificationID, object: self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveMailSentErrorNotification(notification:)),
                                               name: .mailSentErrorNotificationID,
                                               object: nil
        )
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onMailSentSuccessfully(notification:)),
                                               name: .updateInboxMessagesNotificationID,
                                               object: nil
        )
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onMailSentSuccessfully(notification:)),
                                               name: .mailSentNotificationID,
                                               object: nil
        )
    }
    
    deinit {
        bindables.forEach({
            $0.cancel()
        })
        bindables.removeAll()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        tableView?.estimatedRowHeight = 50.0
        tableView?.rowHeight = UITableView.automaticDimension
        
        tableView?.delegate = self
        tableView?.dataSource = self
        
        tableView?.register(ComposeMailFromEmailCell.self, forCellReuseIdentifier: ComposeMailFromEmailCell.className)
        
        tableView?.register(UINib(nibName: ComposeMailOtherEmailCell.className,
                                  bundle: Bundle(for: ComposeMailOtherEmailCell.self)),
                            forCellReuseIdentifier: toCellId)
        tableView?.register(UINib(nibName: ComposeMailOtherEmailCell.className,
                                  bundle: Bundle(for: ComposeMailOtherEmailCell.self)),
                            forCellReuseIdentifier: ccCellId)
        tableView?.register(UINib(nibName: ComposeMailOtherEmailCell.className,
                                  bundle: Bundle(for: ComposeMailOtherEmailCell.self)),
                            forCellReuseIdentifier: bccellId)

        tableView.register(AttachmentCell.self, forCellReuseIdentifier: AttachmentCell.className)
        tableView?.register(ComposeMailSubjectCell.self, forCellReuseIdentifier: ComposeMailSubjectCell.className)
        tableView?.register(ComposeMailMenuCell.self, forCellReuseIdentifier: ComposeMailMenuCell.className)
        
        tableView?.register(UINib(nibName: ComposeMailBodyCell.className,
                                  bundle: Bundle(for: ComposeMailBodyCell.self)),
                            forCellReuseIdentifier: ComposeMailBodyCell.className)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemBackground
        tableView?.backgroundView = backgroundView
        
        tableView?.separatorStyle = .singleLine
        tableView?.separatorInset = .zero
        
        tableView.keyboardDismissMode = .interactive
        
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    private func setupVM() {
        viewModel.setupDatasource()
    }
    
    private func setupObservers() {
        // Bindings
        bindables = [
            viewModel
                .$answerMode
                .receive(on: RunLoop.main)
                .sink { [weak self] (output) in
                    self?.updateNavigationTitle(by: output)
            },
            
            viewModel
                .showBanner
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] (value) in
                    self?.showBanner(withTitle: value,
                                     additionalConfigs: [.displayDuration(2.0),
                                                         .showButton(false)])
                }),
 
            viewModel
                .showAlert
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] (value) in
                    self?.showAlert(with: value.0, onCompletion: { [weak self] in
                        if value.1 {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    })
                    
                }),
            
            viewModel
                .reloadSections
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] (indexSet) in
                    self?.tableView.reloadSections(indexSet, with: .automatic)
                }),
            
            viewModel
                .reloadWholeList
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] in
                    self?.tableView.reloadData()
                }),
            
            viewModel
                .$shouldEnableSendButton
                .sink(receiveValue: { [weak self] (shouldEnable) in
                    self?.navigationItem.rightBarButtonItem?.isEnabled = shouldEnable
                })
        ]
    }
    
    @objc
    private func receiveMailSentErrorNotification(notification: Notification) {
        DispatchQueue.main.async {
            if let params = notification.object as? AlertKitParams {
                self.showAlert(with: params, onCompletion: {})
            }
        }
    }
    
    @objc
    private func onMailSentSuccessfully(notification: Notification) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - UI
    private func updateNavigationTitle(by output: AnswerMessageMode) {
        switch output {
        case .newMessage:
            navigationItem.title = Strings.Compose.newMessage.localized
        case .reply:
            navigationItem.title = Strings.Compose.reply.localized
        case .replyAll:
            navigationItem.title = Strings.Compose.relpyAll.localized
        case .forward:
            navigationItem.title = Strings.Compose.forward.localized
        }
    }
    
    private func setupNavigationItem() {
        navigationController?.prefersLargeTitle = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.updateTintColor()
        
        setupLeftBarButtonItems()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "SendButton"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(onTapSend(_:)))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc
    private func onTapSend(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        showBanner(withTitle: Strings.Banner.mailSendingAlert.localized,
                   additionalConfigs: [.displayDuration(2.0),
                                       .showButton(false)]
        )
        viewModel.prepareMessadgeToSend()
    }
    
    // MARK: - Actions
    @objc
    private func backButtonPressed() {
        if viewModel.shouldSaveDraft() {
            showDraftActionsView(navigationItem.leftBarButtonItem)
        } else {
            viewModel.deleteDraft()
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(for: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = viewModel.rowDetails(at: indexPath) else {
            return UITableViewCell()
        }
        
        switch row {
        case .from:
            return configureFromCell(at: indexPath)
        case .to,
             .cc,
             .bcc:
            var identifier = ""
            switch row {
            case .to:
                identifier = toCellId
            case .cc:
                identifier = ccCellId
            case .bcc:
                identifier = bccellId
            default: break
            }
            return configurePrefixCell(at: indexPath, with: identifier)
        case .subject:
            return configureSubjectCell(at: indexPath)
        case .menu:
            return configureMenuCell(at: indexPath)
        case .attachment:
            return configureAttachmentCell(at: indexPath)
        case .body:
            return configureBodyCell(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.rowHeight(at: indexPath) ?? UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - Helpers
extension ComposeController {
    func showMailBoxes(_ mailBoxes: [Mailbox],
                       rect: CGRect,
                       selectMailId: String,
                       onUpdateMailAddress: @escaping ((String?) -> Void)) {
        let controller = UIAlertController(title: "\(Strings.AppSettings.mailSettings.localized) \(Strings.AppSettings.addresses.localized)",
            message: nil,
            preferredStyle: .actionSheet)
        
        mailBoxes.forEach({ (mailBox) in
            let title = mailBox.email == selectMailId ? "\(mailBox.email ?? "") ✔︎" : mailBox.email ?? ""
            let action = UIAlertAction(title: title, style: .default) { (_) in
                onUpdateMailAddress(mailBox.email)
                controller.dismiss(animated: true, completion: nil)
            }
            controller.addAction(action)
        })
        
        let cancelAction = UIAlertAction(title: Strings.Button.cancelButton.localized, style: .cancel) { (_) in
            controller.dismiss(animated: true, completion: nil)
        }
        
        controller.addAction(cancelAction)
        
        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceRect = rect
            popoverController.sourceView = view
        }
        
        present(controller, animated: true, completion: nil)
    }
    
    func showDraftActionsView(_ sender: UIBarButtonItem?) {
        let discardActionSheet = UIAlertController(title: Strings.Compose.SelectDraftOption.localized,
                                                   message: nil,
                                                   preferredStyle: .actionSheet)
        discardActionSheet.addAction(.init(title: Strings.Compose.discardDraft.localized,
                                                   style: .destructive, handler:
            { [weak self] (_) in
                self?.viewModel?.deleteDraft()
                self?.navigationController?.popViewController(animated: true)
        }))
        
        discardActionSheet.addAction(UIAlertAction(title: Strings.Compose.saveDraft.localized,
                                                   style: .default, handler:
            { [weak self] (_) in
                self?.viewModel?.saveDraft()
                self?.navigationController?.popViewController(animated: true)
        }))
        
        discardActionSheet.addAction(.init(title: Strings.Button.cancelButton.localized,
                                           style: .cancel,
                                           handler:
            { (_) in
                discardActionSheet.dismiss(animated: true, completion: nil)
        }))
        
        if let popoverController = discardActionSheet.popoverPresentationController {
            popoverController.barButtonItem = sender
            popoverController.sourceView = view
        }
        present(discardActionSheet, animated: true, completion: nil)
    }
    
    func showAlert(withTitle title: String, message: String) {
        showAlert(with: title,
                  message: message,
                  buttonTitle: Strings.Button.closeButton.localized)
    }
}

// MARK: - Menu Actions
extension ComposeController {
    func onTapAttachment(_ sender: UIButton, onCompletion: @escaping ((URL) -> Void)) {
        let pickerAlert = UIAlertController(title: Strings.Compose.SelectDraftOption.localized,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickerAlert.addAction(.init(title: Strings.Compose.camera.localized,
                                        style: .default, handler:
                { [weak self] (_) in
                    self?.router?.showImagePickerWithCamera({ (url) in
                        onCompletion(url)
                    })
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) || UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            pickerAlert.addAction(.init(title: Strings.Compose.photoLibrary.localized,
                                        style: .default, handler:
                { [weak self] (_) in
                    self?.router?.showImagePickerWithLibrary({ (url) in
                        onCompletion(url)
                    })
            }))
        }
        
        pickerAlert.addAction(.init(title: Strings.Compose.fromAnotherApp.localized,
                                    style: .default, handler:
            { [weak self] (_) in
                self?.showDocumentPicker({ (url) in
                    onCompletion(url)
                })
        }))
        
        pickerAlert.addAction(.init(title: Strings.Button.cancelButton.localized,
                                           style: .cancel,
                                           handler:
            { (_) in
                pickerAlert.dismiss(animated: true, completion: nil)
        }))

        if let popoverController = pickerAlert.popoverPresentationController {
            popoverController.sourceRect = sender.frame
            popoverController.sourceView = view
        }
        
        present(pickerAlert, animated: true, completion: nil)
    }
    
    func showDocumentPicker(_ onCompletion: ((URL) -> Void)?) {
        onPickupDocumentFromPicker = onCompletion
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),
                                                                            String(kUTTypeContent),
                                                                            String(kUTTypeItem),
                                                                            String(kUTTypeData),
                                                                            String(kUTTypePDF),
                                                                            String(kUTTypeImage)], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }

    func showPreviewScreen(url: URL, encrypted: Bool) {
        if encrypted {
            guard let data = try? Data(contentsOf: url) else {
                DPrint("Attachment content data error!")
                showAlert(with: Strings.AppError.attachmentErrorTitle.localized,
                          message: Strings.AppError.attachmentErrorMessage.localized,
                          buttonTitle: Strings.Button.closeButton.localized)
                return
            }
            
            if let tempUrl = viewModel.decryptAttachment(data: data) {
                documentInteractionController.url = tempUrl
            } else {
                DPrint("Attachment decrypted content data error!")
                documentInteractionController.url = url
            }
        } else {
            documentInteractionController.url = url
        }
        
        documentInteractionController
            .uti = url.typeIdentifier ?? "public.data, public.content"
        
        documentInteractionController
            .name = url.localizedName ?? url.lastPathComponent
        
        DispatchQueue.main.async {
            self.documentInteractionController.presentPreview(animated: true)
        }
        
        Loader.start()
    }
    
    func loadAttachFile(url: String, encrypted: Bool) {
        viewModel.getAttachment(from: url,
                                encrypted: encrypted)
        { [weak self] (urlObj, encrypted) in
            if let urlObj = urlObj {
                self?.showPreviewScreen(url: urlObj, encrypted: encrypted)
            }
        }
    }
}

extension ComposeController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        DPrint("picked urls:", urls)

        guard let fileUrl = urls.first else {
            return
        }
        
        onPickupDocumentFromPicker?(fileUrl)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        DPrint("UIDocumentPickerViewController dismissed")
    }
}

// MARK: - UIDocumentInteractionControllerDelegate
extension ComposeController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navigationViewController = self.navigationController else {
            return self
        }
        return navigationViewController
    }
    
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        Loader.stop()
    }
}

// MARK: - ViewModel Binding
extension ComposeController: Bindable {
    typealias ModelType = ComposeViewModel
    
    func configure(with model: ComposeViewModel) {
        viewModel = model
    }
}

// MARK: - LeftBarButtonItemConfigurable
extension ComposeController: LeftBarButtonItemConfigurable {
    func setupLeftBarButtonItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrowDark"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backButtonPressed
            )
        )
    }
}
