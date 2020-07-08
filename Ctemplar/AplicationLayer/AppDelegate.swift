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
import Firebase
import Utility
import Networking
import Initializer
import SideMenu
import Inbox

typealias AppResult<T> = Result<T, Error>
typealias Completion<T> = (AppResult<T>) -> Void

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")
        
        DPrint("currentDeviceLanguageCode:", Locale.current.languageCode as Any)
        DPrint("currentAppLanguage:", Locale.preferredLanguages[0])
        
        configureWindow()
        
        configureSideMenu()
        
        setupFirebase()
        
        registerForPushNotifications()
        
        application.applicationIconBadgeNumber = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(onCompleteLogout),
                                               name: .logoutCompleteNotificationID,
                                               object: nil
        )
        
        Fabric.with([Crashlytics.self])
        
        return true
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
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        DPrint("Firebase registration token: \(fcmToken)")
        self.saveAPNDeviceToken(fcmToken)
        if !UtilityManager.shared.keychainService.getUserName().isEmpty {
            NetworkManager.shared.networkService.send(deviceToken: fcmToken) { _ in }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NotificationCenter.default.post(name: .updateInboxMessagesNotificationID, object: false, userInfo: nil)
        completionHandler([.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
            DPrint("Notification data:\n\(userInfo)")
            if let messageId = Int(userInfo["gcm.notification.message_id"] as? String ?? "0") {
                if let window = UIApplication.shared.getKeyWindow() {
                    if let initialzer = window.rootViewController as? InitializerController {
                        initialzer.update(messageId: messageId)
                    } else {
                       initRoot()
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
        SideMenuController.preferences.basic.statusBarBehavior = .hideOnMenu
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
    func showInbox(withMessage message: EmailMessage,
                   folder: String,
                   user: UserMyself,
                   delegate: ViewInboxEmailDelegate?) {
        let viewInboxVC: ViewInboxEmailViewController = UIStoryboard(storyboard: .inboxDetails,
                                                                     bundle: Bundle(for: ViewInboxEmailViewController.self)
        ).instantiateViewController()
        viewInboxVC.message = message
        viewInboxVC.messageID = message.messsageID
        viewInboxVC.currentFolderFilter = folder
        viewInboxVC.viewInboxEmailDelegate = delegate
        viewInboxVC.user = user
        (delegate as? UIViewController)?
            .navigationController?
            .pushViewController(viewInboxVC, animated: true
        )
    }
    
    func showSearch(withMessage messages: [EmailMessage],
                    user: UserMyself,
                    presenter: UIViewController?) {
        let searchVC: SearchViewController = UIStoryboard(storyboard: .search,
                                                          bundle: Bundle(for: SearchViewController.self)
        ).instantiateViewController()
        searchVC.messagesList = messages
        searchVC.user = user
        presenter?.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func showCompose(withMode mode: Utility.AnswerMessageMode,
                     user: UserMyself,
                     presenter: UIViewController?) {
        let composeVC: ComposeViewController = UIStoryboard(storyboard: .compose,
                                                          bundle: Bundle(for: ComposeViewController.self)
        ).instantiateViewController()
        switch mode {
        case .forward:
            composeVC.answerMode = AnswerMessageMode.forward
        case .newMessage:
            composeVC.answerMode = AnswerMessageMode.newMessage
        case .reply:
            composeVC.answerMode = AnswerMessageMode.reply
        case .replyAll:
            composeVC.answerMode = AnswerMessageMode.replyAll
        }
        composeVC.user = user
        presenter?.navigationController?.pushViewController(composeVC, animated: true)
    }
    
    func showComposeWithDraft(withMessage message: EmailMessage,
                              withMode mode: Utility.AnswerMessageMode,
                              user: UserMyself,
                              presenter: UIViewController?) {
        let composeVC: ComposeViewController = UIStoryboard(storyboard: .compose,
                                                          bundle: Bundle(for: ComposeViewController.self)
        ).instantiateViewController()
        
        composeVC.message = message
        composeVC.user = user
        
        if let children = message.children {
            if !children.isEmpty {
                composeVC.messagesArray = children
            }
        }
        
        if let draftSubject = message.subject {
            composeVC.subject = draftSubject
        }
        
        switch mode {
        case .forward:
            composeVC.answerMode = AnswerMessageMode.forward
        case .newMessage:
            composeVC.answerMode = AnswerMessageMode.newMessage
        case .reply:
            composeVC.answerMode = AnswerMessageMode.reply
        case .replyAll:
            composeVC.answerMode = AnswerMessageMode.replyAll
        }
        presenter?.show(composeVC, sender: self)
    }
    
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
    
    func showManageFolders(withFolders folders: [Folder],
                           user: UserMyself,
                           presenter: UIViewController?) {
        let manageFoldersVC: ManageFoldersViewController = UIStoryboard(storyboard: .manageFolders,
                                                              bundle: Bundle(for: ManageFoldersViewController.self)
        ).instantiateViewController()
        manageFoldersVC.setup(folderList: folders)
        manageFoldersVC.setup(user: user)
        let navController = UIViewController.getNavController(rootViewController: manageFoldersVC)
        navController.prefersLargeTitle = true
        presenter?
            .sideMenuController?
            .setContentViewController(to: navController, animated: true, completion: {
                presenter?.sideMenuController?.hideMenu()
        })
    }
    
    func showSettings(ofUser user: UserMyself, presenter: UIViewController?) {
        let settingsVC: SettingsViewController = UIStoryboard(storyboard: .settings,
                                                              bundle: Bundle(for: SettingsViewController.self)
        ).instantiateViewController()
        settingsVC.user = user
        let navController = UIViewController.getNavController(rootViewController: settingsVC)
        navController.prefersLargeTitle = true
        presenter?
            .sideMenuController?
            .setContentViewController(to: navController, animated: true, completion: {
                presenter?.sideMenuController?.hideMenu()
        })
    }
    
    func showContacts(withList contacts: [Contact],
                      contactsEncrypted: Bool,
                      presenter: UIViewController?) {
        let contactsVC: ContactsViewController = UIStoryboard(storyboard: .contacts,
                                                              bundle: Bundle(for: ContactsViewController.self)
        ).instantiateViewController()
        contactsVC.contactsList = contacts
        contactsVC.contactsEncrypted = contactsEncrypted
        let navController = UIViewController.getNavController(rootViewController: contactsVC)
        navController.prefersLargeTitle = true
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
        
        // Show Inbox
        initializer.onTapViewInbox = { [weak self]
            (message, folder, user, delegate) in
            self?.showInbox(withMessage: message,
                            folder: folder,
                            user: user,
                            delegate: delegate
            )
        }
        
        // Open Search
        initializer.onTapSearch = { [weak self] (messages, user, inboxViewController) in
            self?.showSearch(withMessage: messages,
                             user: user,
                             presenter: inboxViewController
            )
        }
        
        // Open Contacts
        initializer.onTapContacts = { [weak self] (contacts, contactsEncrypted, inboxViewController) in
            self?.showContacts(withList: contacts,
                               contactsEncrypted: contactsEncrypted,
                               presenter: inboxViewController
            )
        }
        
        // Open Settings
        initializer.onTapSettings = { [weak self] (user, inboxViewController) in
            self?.showSettings(ofUser: user, presenter: inboxViewController)
        }
        
        // Open Manage Folders
        initializer.onTapManageFolders = { [weak self] (folders, user, inboxViewController) in
            self?.showManageFolders(withFolders: folders,
                                    user: user,
                                    presenter: inboxViewController
            )
        }
        
        // Open FAQ
        initializer.onTapFAQ = { [weak self] (inboxViewController) in
            self?.showFAQ(from: inboxViewController)
        }
        
        // Compose
        initializer.onTapCompose = { [weak self] (mode, user, inboxViewController) in
            self?.showCompose(withMode: mode,
                              user: user,
                              presenter: inboxViewController
            )
        }
        
        // Compose with draft
        initializer.onTapComposeWithDraft = { [weak self] (mode, message, user, inboxViewController) in
            self?.showComposeWithDraft(withMessage: message,
                                       withMode: mode,
                                       user: user,
                                       presenter: inboxViewController
            )
        }
    }
}
