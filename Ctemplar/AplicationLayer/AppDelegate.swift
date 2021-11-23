//
//  AppDelegate.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import UserNotifications
import FirebaseCore
import FirebaseMessaging
import Utility
import Networking
import Initializer
import SideMenu
import Inbox
import InboxViewer
import Combine
import IQKeyboardManagerSwift
import EMAlertController
import Sentry
import AppSettings

typealias AppResult<T> = Result<T, Error>
typealias Completion<T> = (AppResult<T>) -> Void

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var anyCancellable: AnyCancellable?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Clear existing any token/credentials stored.
        if (!UserDefaults.standard.bool(forKey: "IsFirst")) {
            UtilityManager.shared.keychainService.deleteUserCredentialsAndToken()
            UserDefaults.standard.set(true, forKey: "IsFirst")
        }
   
        
        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")
        
        
        SentrySDK.start { options in
               options.dsn = "https://dfb816a066a0448ba631d7602bef50da@o190614.ingest.sentry.io/5461858"
               options.debug = true // Enabled debug when first installing is always helpful
           }
        
 
        
        
        UtilityManager.shared.setupReachability()
        
        anyCancellable = UtilityManager
            .shared
            .subject
            .subscribe(on: RunLoop.main)
            .sink(receiveCompletion: { (completion) in
                DPrint(completion)
            }) { [weak self] (isNetworkAvailable) in
                DPrint("Network Available: \(isNetworkAvailable)")
                if !isNetworkAvailable {
                    self?.presentEmptyState()
                } else {
                    self?.removeEmptyState()
                }
        }
        
        IQKeyboardManager.shared.enable = true
        
        configureWindow()
        
        configureSideMenu()
        
        setupFirebase()
        
        registerForPushNotifications()
        
        registerForInAPP()
        
        application.applicationIconBadgeNumber = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(onCompleteLogout),
                                               name: .logoutCompleteNotificationID,
                                               object: nil
        )
        
        NotificationCenter.default.addObserver(forName: .disableIQKeyboardManagerNotificationID,
                                               object: nil,
                                               queue: .main) { (notification) in
            if let vc = notification.object as? UIViewController {
                IQKeyboardManager.shared.disabledToolbarClasses = [type(of: vc)]
            }
        }
        
        NotificationCenter.default.addObserver(forName: .showForceAppUpdateAlertNotificationID,
                                               object: nil,
                                               queue: .main) { (_) in
            self.showForceUpdateAlert()
        }
        
        Fabric.with([Crashlytics.self])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.addBlurViewToTheWindow()
            self.triggerBiometric()
        }
        return true
    }

    func registerForInAPP(){
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func triggerBiometric () {
        if let blurView = UIApplication.shared.getKeyWindow()?.subviews.first(where: { $0 is AppBlurView }) as? AppBlurView {
            let topVC = getTopViewController()
            
            guard let parent = topVC.parent, !(parent is InitializerController) else {
                blurView.removeFromSuperview()
                return
            }
            
            blurView.triggerBiometric {
                DispatchQueue.main.async {
                    blurView.removeFromSuperview()
                }
            } onFailure: { [weak self] (message) in
                DispatchQueue.main.async {
                    let topVC = self?.getTopViewController()
                    topVC?.showAlert(with: "Unautorized", message: message, buttonTitle: "Ok")
                }
            }
        }
    }
    private func setupFirebase() {
        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: filePath)
            else { return }
        FirebaseApp.configure(options: options)
        Messaging.messaging().delegate = self
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        addBlurViewToTheWindow()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        showForceUpdateAlert()
      //  self.refreshToken()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
        
        self.triggerBiometric()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UtilityManager.shared.stopReachability()
        anyCancellable?.cancel()
        anyCancellable = nil
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let action = userInfo["gcm.notification.action"] as? String {
            DPrint("push notification received for: \(action)")
            if action == "changePassword" {
                UtilityManager.shared.keychainService.deleteUserCredentialsAndToken()
                switch application.applicationState {
                case .active, .background:
                    initRoot()
                default:
                    break
                }
            }
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    // MARK: - Push notifications
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DPrint("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DPrint("Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        DPrint("APNs device token: \(deviceTokenString)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        DPrint("APNs registration failed: \(error)")
    }
    
    func saveAPNDeviceToken(_ token: String) {
        UtilityManager.shared.keychainService.saveAPNDeviceToken(token)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            return
        }
        
        DPrint("Firebase registration token: \(fcmToken)")
        
        saveAPNDeviceToken(fcmToken)
        
        if !UtilityManager.shared.keychainService.getUserName().isEmpty {
            NetworkManager.shared.networkService.send(deviceToken: fcmToken) { _ in }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NotificationCenter.default.post(name: .newMessagesNotificationID, object: true, userInfo: nil)
        completionHandler([.sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
            DPrint("Notification data:\n\(userInfo)")
            if let messageId = Int(userInfo["gcm.notification.message_id"] as? String ?? "0") {
                if let window = UIApplication.shared.getKeyWindow() {
                    if let sideMenu = window.rootViewController as? SideMenuController,
                        let contentVC = sideMenu.contentViewController as? InboxNavigationController {
                        if let inboxListVC = contentVC.viewControllers.first as? InboxViewerPushable {
                            inboxListVC.openInboxViewer(of: messageId)
                        } else {
                            if let inboxSideMenu = sideMenu.menuViewController as? InboxSideMenuController {
                                SharedInboxState.shared.update(incomingMessageId: messageId)
                                inboxSideMenu.resetToInbox()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Observers
    @objc
    private func onCompleteLogout() {
        initRoot()
    }
}

// MARK: - Side Menu Preferences
private extension AppDelegate {
    func configureSideMenu() {
        SideMenuController.preferences.basic.menuWidth = 240
        SideMenuController.preferences.basic.position = .sideBySide
        SideMenuController.preferences.basic.direction = .left
        SideMenuController.preferences.basic.enablePanGesture = true
        SideMenuController.preferences.basic.supportedOrientations = .allButUpsideDown
        SideMenuController.preferences.basic.shouldRespectLanguageDirection = true
    }
}
// MARK: - Common Callbacks
/// Common Callbacks from different Module
private extension AppDelegate {
    func showFAQ(from presenter: UIViewController?) {
        let faqVC: FAQViewController = UIStoryboard(storyboard: .FAQ,
                                                              bundle: Bundle(for: FAQViewController.self)
        ).instantiateViewController()
        let navController = UIViewController.getNavController(rootViewController: faqVC)
        presenter?
            .sideMenuController?
            .setContentViewController(to: navController, animated: true, completion: {
                presenter?.sideMenuController?.hideMenu()
        })
    }
}

// MARK: - Root Initialization
private extension AppDelegate {
    func configureWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        initRoot()
        window?.makeKeyAndVisible()
    }
    
    func initRoot() {
        let initializer: InitializerController = UIStoryboard(storyboard: .initializer,
                                                              bundle: Bundle(for: InitializerController.self)
        ).instantiateViewController()
        handleCallbacks(from: initializer)
        window?.rootViewController = initializer
    }
    
    func handleCallbacks(from initializer: InitializerController) {
        // Handle Callbacks

        // Open FAQ
        initializer.onTapFAQ = { [weak self] (inboxViewController) in
            self?.showFAQ(from: inboxViewController)
        }
    }
}

// MARK: - Empty State Presentation
extension AppDelegate {
    func presentEmptyState() {
        if let root = window?.rootViewController as? SideMenuController,
            let inboxNav = root.children.first(where: { $0 is InboxNavigationController }) as? InboxNavigationController,
            let topVC = inboxNav.topViewController as? EmptyStateMachine {
            topVC.showEmptyState()
        }
    }
    
    func removeEmptyState() {
        if let root = window?.rootViewController as? SideMenuController,
            let inboxNav = root.children.first(where: { $0 is InboxNavigationController }) as? InboxNavigationController,
            let topVC = inboxNav.topViewController as? EmptyStateMachine {
            topVC.removeEmptyState()
        }
    }
    
    private func addBlurViewToTheWindow() {
        guard let window = UIApplication.shared.getKeyWindow(),
              !window.subviews.contains(where: { $0 is AppBlurView }) else {
            return
        }
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = AppBlurView(effect: blurEffect)
        blurEffectView.frame = window.frame
        window.addSubview(blurEffectView)
    }
}

// MARK: - Force Update Alert
private extension AppDelegate {
    func showForceUpdateAlert() {
        guard let storeVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            NetworkManager.shared.apiService.checkAppVersion { (appVersion, isForceUpdate) in
                DispatchQueue.main.async {
                    if storeVersion.compare(appVersion, options: .numeric) == .orderedAscending, isForceUpdate {
                        var message = Strings.ForceUpdate.UpdateAvailableMessage.localized
                        message = message.replacingOccurrences(of: "%s", with: appVersion)
                        let alertConfig = AppVersionAlertConfig(title: Strings.ForceUpdate.UpdateAvailableTitle.localized,
                                                                message: message,
                                                                image: #imageLiteral(resourceName: "Slice"),
                                                                alertButtons: [.init(title: Strings.ForceUpdate.GoToStore.localized,
                                                                                     type: .cancel,
                                                                                     action: {
                                                                                        if let url = URL(string: "itms-apps://apple.com/app/id1495837525") {
                                                                                            UIApplication.shared.open(url)
                                                                                        }
                                                                                     })
                                                                ]
                        )
                        
                        self.showImageAlert(withConfig: alertConfig)
                    }
                }
            }
        }
    }
    
    func showImageAlert(withConfig config: AppVersionAlertConfig) {
        let alert = EMAlertController(title: config.title, message: config.message)
        alert.iconImage = config.image
        alert.dataDetectorTypes = .all
        alert.backgroundColor = .systemBackground
        alert.titleColor = .label
        alert.messageColor = .label
        alert.cornerRadius = 10
        for button in config.alertButtons {
            let alertButton = EMAlertAction(title: button.title, style: button.type, action: button.action)
            alertButton.titleFont = UIFont.preferredFont(forTextStyle: .headline)
            alert.addAction(alertButton)
        }
        
        let topVC = getTopViewController()
        topVC.present(alert, animated: true, completion: nil)
    }
    
    func getTopViewController() -> UIViewController {
        if let window = UIApplication.shared.getKeyWindow() {
            if let sideMenu = window.rootViewController as? SideMenuController,
                let contentNavigationVC = sideMenu.contentViewController as? InboxNavigationController {
                return contentNavigationVC
            } else if let initializerController = window.rootViewController as? InitializerController,
                      let loginController = initializerController.children.first {
                if let signupVC = loginController.presentedViewController {
                    return signupVC
                } else {
                    return loginController
                }
            } else {
                fatalError("Not able to find any root controller")
            }
        }
        fatalError("Not able to find any key window")
    }
    
    func refreshToken() {
        Loader.start()
        NetworkManager.shared.apiService.refreshToken() { (complete) in
            Loader.stop()
            if complete {
                return
            }
        }
    }
}
