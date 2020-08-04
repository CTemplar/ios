import Foundation
import UIKit
import Utility

class SelectLanguageViewController: UIViewController {
   
    // MARK: Properties
    private let identifier = "LanguageCell"
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarTitle()
    }
    
    // MARK: - UI Setup
    func setNavigationBarTitle() {
        navigationController?.updateTintColor()
        title = Strings.Language.languageTitle.localized
    }
    
    func registerTableViewCell() {
        tableView.tintColor = AppStyle.Colors.loaderColor.color
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
    }
    
    // MARK: - Actions
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Language Helper
    func isLanguageSelected(index: Int) -> Bool {
        var language = ""
        let currentLanguage = Bundle.getLanguage()
        
        switch index {
        case GeneralConstant.Language.english.rawValue:
            language = GeneralConstant.Language.english.prefix
        case GeneralConstant.Language.russian.rawValue:
            language = GeneralConstant.Language.russian.prefix
        case GeneralConstant.Language.french.rawValue:
            language = GeneralConstant.Language.french.prefix
        case GeneralConstant.Language.slovak.rawValue:
            language = GeneralConstant.Language.slovak.prefix
        default:
            language = GeneralConstant.Language.english.prefix
        }
        return language == currentLanguage
    }
    
    func selectLangage(language: String) {
        Bundle.setLanguage(lang: language)
        setNavigationBarTitle()
        tableView.reloadData()
        NotificationCenter.default.post(name: .reloadViewControllerNotificationID, object: nil, userInfo: nil)
        Loader.stop(in: self)
    }
}

// MARK: - UITableViewDelegate & UITableViewDatasource
extension SelectLanguageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GeneralConstant.Language.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        var languageName = ""
        
        switch indexPath.row {
        case GeneralConstant.Language.english.rawValue:
            languageName = GeneralConstant.Language.english.name
        case GeneralConstant.Language.russian.rawValue:
            languageName = GeneralConstant.Language.russian.name
        case GeneralConstant.Language.french.rawValue:
            languageName = GeneralConstant.Language.french.name
        case GeneralConstant.Language.slovak.rawValue:
            languageName = GeneralConstant.Language.slovak.name
        default: break
        }
        
        let selected = self.isLanguageSelected(index: indexPath.row)
        
        setupData(for: cell, with: languageName, isSelected: selected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var languagePrefix = ""
        
        switch indexPath.row {
        case GeneralConstant.Language.english.rawValue:
            languagePrefix = GeneralConstant.Language.english.prefix
        case GeneralConstant.Language.russian.rawValue:
            languagePrefix = GeneralConstant.Language.russian.prefix
        case GeneralConstant.Language.french.rawValue:
            languagePrefix = GeneralConstant.Language.french.prefix
        case GeneralConstant.Language.slovak.rawValue:
            languagePrefix = GeneralConstant.Language.slovak.prefix
        default:
            languagePrefix = GeneralConstant.Language.english.prefix
        }
        
        Loader.start(presenter: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.selectLangage(language: languagePrefix)
        }
    }
    
    // MARK: - Cell Configuration
    func setupData(for cell: UITableViewCell, with languageName: String, isSelected: Bool) {
        cell.textLabel?.textColor = k_cellTitleTextColor
        cell.textLabel?.font = AppStyle.CustomFontStyle.Regular.font(withSize: 16.0)
        cell.textLabel?.text = languageName
        cell.accessoryType = isSelected ? .checkmark : .none
    }
}
