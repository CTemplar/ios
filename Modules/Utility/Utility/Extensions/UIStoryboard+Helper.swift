import UIKit

public extension UIStoryboard {
    enum Storyboard: String {
        case signup = "Signup"
        case login = "Login"
        case forgetPassword = "ForgetPassword"
        case inbox, inboxFilter = "Inbox"
        case inboxSideMenu = "InboxSideMenu"
        case manageFolders = "ManageFolders"
        case moveTo = "MoveTo"
        case editFolder = "EditFolder"
        case addFolder = "AddFolder"
        case compose = "Compose"
        case initializer = "Initializer"
        case inboxDetails = "ViewInboxEmail"
        case search = "GlobalSearch"
        case contacts = "Contacts"
        case settings = "Settings"
        case FAQ = "FAQ"
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
    var viewControllerId: String {
        switch self {
        case .login:
            return "Login.LoginViewController"
        case .signup:
            return "Signup.SignupViewController"
        case .forgetPassword:
            return "ForgetPassword.ForgetPasswordViewController"
        case .inbox:
            return "Inbox.InboxViewController"
        case .inboxFilter:
            return "Inbox.InboxFilterViewController"
        case .inboxSideMenu:
            return "Inbox.InboxSideMenu"
        case .manageFolders:
            return "Inbox.ManageFolders"
        case .moveTo:
            return "Inbox.MoveToViewController"
        case .editFolder:
            return "Inbox.EditFolderViewController"
        case .addFolder:
            return "Inbox.AddFolderViewController"
        case .compose:
            return "ComposeViewController"
        case .initializer:
            return "Initializer.InitializerController"
        case .inboxDetails:
            return "ViewInboxEmailViewController"
        case .search:
            return "GlobalSearchViewController"
        case .contacts:
            return "ContactsViewController"
        case .settings:
            return "SettingsViewController"
        case .FAQ:
            return "FAQViewController"
        }
    }
    
    var bundle: Bundle {
        guard let classType = NSClassFromString(self.viewControllerId) else {
            fatalError("Couldn't find class with identifier: \(self.viewControllerId)")
        }
        return Bundle(for: classType)
    }
}
