import UIKit
import Utility

class PGPKeysViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var fingerprintTitleLabel: UILabel!
    @IBOutlet weak var fingerprintValueLabel: UILabel!
    @IBOutlet weak var emailTileLabel: UILabel!
    @IBOutlet weak var emailValueTextField: UITextField!
    
    @IBOutlet weak var downButton: UIButton!
    
    
    @IBOutlet weak var addNewKeyBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: Properties
    private (set) var presenter: PGPKeysPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        presenter = PGPKeysPresenter(parentController: self)
        presenter?.setupUI()
        presenter?.getMailBoxList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = Strings.AppSettings.keys.localized
    }
    
    // MARK: - Setup
    func setup(presenter: PGPKeysPresenter?) {
        self.presenter = presenter
    }
    
    // MARK: - Actions
    @IBAction func onTapMailBox(_ sender: UIButton) {
        presenter?.onTapMailbox(from: sender)
    }
    
   
    
    @IBAction func addNewKeyBtnTapped(_ sender: Any) {
        presenter?.onTapAddKey()
    }
}

extension PGPKeysViewController: AliasKeyDelegate {
    func getEmail() -> String {
        return  self.presenter?.getEmail() ?? ""
    }
    
    
    func refreshData() {
        self.presenter?.getMailBoxList(true)
    }
}
