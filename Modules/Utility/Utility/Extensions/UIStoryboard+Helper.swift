import UIKit

public extension UIStoryboard {
    enum Storyboard: String {
        case signup = "Signup"
        case login = "Login"
        case forgetPassword = "ForgetPassword"
        case inbox, inboxFilter = "Inbox"
        case inboxViewer = "InboxViewer"
        case inboxSideMenu = "InboxSideMenu"
        case manageFolders = "ManageFolders"
        case moveTo = "MoveTo"
        case editFolder = "EditFolder"
        case addFolder = "AddFolder"
        case compose = "Compose"
        case initializer = "Initializer"
        case inboxDetails = "ViewInboxEmail"
        case search = "GlobalSearch"
        case contacts = "AppContacts"
        case FAQ = "FAQ"
        case dashboard = "Dashboard"
        case settings = "AppSettings"
        case whiteBlackLists = "WhiteBlackLists"
        case language = "SelectLanguage"
        case encryption = "Encryption"
        case signature = "Signature"
        case key = "PGPKey"
        case address = "Alias"
        case emptyState = "EmptyState"
        case setPassword = "SetPassword"
        case scheduler = "Scheduler"
        case filter = "Filter"
        
        
      public  static var inboxPassword:Storyboard { .inboxViewer}
      public  static var addNewKey:Storyboard { .key}

        
    }
    
    // MARK: - Convenience Initializers
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    // MARK: - Class Functions
    class func storyboard(_ storyboard: Storyboard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.rawValue, bundle: bundle)
    }
    
    // MARK: - View Controller Instantiation from Generics
    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        
        return viewController
    }
}

public extension UIStoryboard.Storyboard {
    var viewControllerId: (bundlename: String, storyboardId: String) {
        switch self {
        case .login:
            return (bundlename: "Login.LoginViewController", storyboardId: "LoginViewController")
        case .signup:
            return (bundlename: "Signup.SignupViewController", storyboardId: "SignupViewController")
        case .forgetPassword:
            return (bundlename: "ForgetPassword.ForgetPasswordViewController", storyboardId: "ForgetPasswordViewController")
        case .inbox:
            return (bundlename: "Inbox.InboxViewController", storyboardId: "InboxViewController")
        case .inboxViewer:
            return (bundlename: "Inbox.InboxViewer.InboxViewerController", storyboardId: "InboxViewerController")
        case .inboxFilter:
            return (bundlename: "Inbox.InboxFilterViewController", storyboardId: "InboxFilterViewController")
        case .inboxSideMenu:
            return (bundlename: "Inbox.InboxSideMenuController", storyboardId: "InboxSideMenuController")
        case .manageFolders:
            return (bundlename: "Inbox.ManageFoldersViewController", storyboardId: "ManageFoldersViewController")
        case .moveTo:
            return (bundlename: "InboxViewer.InboxViewerController", storyboardId: "InboxViewerController")
        case .editFolder:
            return (bundlename: "Inbox.EditFolderViewController", storyboardId: "EditFolderViewController")
        case .addFolder:
            return (bundlename: "Inbox.AddFolderViewController", storyboardId: "AddFolderViewController")
        case .compose:
            return (bundlename: "Main.ComposeViewController", storyboardId: "ComposeViewController")
        case .initializer:
            return (bundlename: "Initializer.InitializerController", storyboardId: "InitializerController")
        case .inboxDetails:
            return (bundlename: "InboxViewer.InboxViewerController", storyboardId: "InboxViewerController")
        case .search:
            return (bundlename: "GlobalSearch.GlobalSearchViewController", storyboardId: "GlobalSearchViewController")
        case .contacts:
            return (bundlename: "AppContacts.AppContactsViewController", storyboardId: "AppContactsViewController")
        case .settings:
            return (bundlename: "AppSettings.AppSettingsController", storyboardId: "AppSettingsController")
        case .dashboard:
            return (bundlename: "AppSettings.DashboardTableViewController", storyboardId: "DashboardTableViewController")
        case .FAQ:
            return (bundlename: "AppSettings.FAQViewController", storyboardId: "FAQViewController")
        case .whiteBlackLists:
            return (bundlename: "AppSettings.WhiteBlackListsViewController", storyboardId: "WhiteBlackListsViewController")
        case .language:
            return (bundlename: "AppSettings.SelectLanguageViewController", storyboardId: "SelectLanguageViewController")
        case .encryption:
            return (bundlename: "AppSettings.EncryptionController", storyboardId: "EncryptionController")
        case .signature:
            return (bundlename: "AppSettings.SignatureViewController", storyboardId: "SignatureViewController")
        case .key:
            return (bundlename: "AppSettings.PGPKeysViewController", storyboardId: "PGPKeysViewController")
        case .address:
            return (bundlename: "AppSettings.AliasController", storyboardId: "AliasController")

        case .emptyState:
            return (bundlename: "Utility.EmptyStateViewController", storyboardId: "EmptyStateViewController")
        case .setPassword:
            return (bundlename: "Compose.SetPasswordViewController", storyboardId: "SetPasswordViewController")
        case .scheduler:
            return (bundlename: "Compose.SchedulerViewController", storyboardId: "SchedulerViewController")
        case .filter:
            return (bundlename: "Filter.FilterVC", storyboardId: "FilterVC")
        }
        
    }
    
    var bundle: Bundle {
        guard let classType = NSClassFromString(self.viewControllerId.bundlename) else {
            fatalError("Couldn't find class with identifier: \(self.viewControllerId)")
        }
        return Bundle(for: classType)
    }
}
