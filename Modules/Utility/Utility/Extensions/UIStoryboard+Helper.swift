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
            return "LoginViewController"
        case .signup:
            return "SignupViewController"
        case .forgetPassword:
            return "ForgetPasswordViewController"
        case .inbox:
            return "InboxViewController"
        case .inboxFilter:
            return "InboxFilterViewController"
        case .inboxSideMenu:
            return "InboxSideMenu"
        case .manageFolders:
            return "ManageFolders"
        case .moveTo:
            return "MoveTo"
        case .editFolder:
            return "EditFolder"
        case .addFolder:
            return "AddFolder"
        }
    }
    
    var bundle: Bundle {
        guard let classType = NSClassFromString(self.viewControllerId) else {
            fatalError("Couldn't find class with identifier: \(self.viewControllerId)")
        }
        return Bundle(for: classType)
    }
}
