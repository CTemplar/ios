import Foundation
import Combine
import Utility
import Networking

struct Message {
    var messageID: String
    var encryptedMessage: String
    var encryptionObject: [String: String]
    var subject: String
    var send: Bool
    var recieversList: [[String]]
    var encrypted: Bool
    var subjectEncrypted: Bool
    var attachments: [[String: String]]
    var selfDestructionDate: String
    var delayedDeliveryDate: String
    var deadManDate: String
    var mailboxId: Int = 0
    var sender: String
}

typealias CompletionWithAlert = ((AlertKitParams, Bool) -> Void)

typealias CompletionWithBanner = ((String) -> Void)

typealias CompletionWithMessage = ((EmailMessage?) -> Void)

final class ComposeFetcher {
    
    // MARK: Properties
    private let apiService = NetworkManager.shared.apiService
    
    // MARK: - API Service
    func updateSendingMessage(withMessageObject msgObject: Message,
                              onCompletion: @escaping CompletionWithMessage,
                              onCompletionWithBanner: @escaping CompletionWithBanner,
                              onCompletionWithAlert: @escaping CompletionWithAlert) {
        apiService.updateSendingMessage(messageID: msgObject.messageID,
                                        mailboxID: msgObject.mailboxId,
                                        sender: msgObject.sender,
                                        encryptedMessage: msgObject.encryptedMessage,
                                        subject: msgObject.subject,
                                        recieversList: msgObject.recieversList,
                                        folder: MessagesFoldersName.sent.rawValue,
                                        send: msgObject.send,
                                        encryptionObject: msgObject.encryptionObject,
                                        encrypted: msgObject.encrypted,
                                        subjectEncrypted: msgObject.subjectEncrypted,
                                        attachments: msgObject.attachments,
                                        selfDestructionDate: msgObject.selfDestructionDate,
                                        delayedDeliveryDate: msgObject.delayedDeliveryDate,
                                        deadManDate: msgObject.deadManDate)
        { (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(let value):
                    if msgObject.send {
                        onCompletionWithBanner(Strings.Banner.mailSendMessage.localized)
                        NotificationCenter.default.post(name: .updateInboxMessagesNotificationID,
                                                        object: true, userInfo: nil)
                    } else {
                        onCompletion(value as? EmailMessage)
                    }
                case .failure(let error):
                    let params = AlertKitParams(
                        title: Strings.AppError.error.localized,
                        message: error.localizedDescription,
                        cancelButton: Strings.Button.closeButton.localized
                    )
                    
                    onCompletionWithBanner(Strings.Banner.sendMailError.localized)
                    onCompletionWithAlert(params, false)
                }
            }
        }
    }
    
    func uploadAttachment(withURL url: URL,
                          messageID: String,
                          isAttachmentsEncrypted: Bool,
                          onCompletionWithAttachment: @escaping ((Attachment?) -> Void),
                          onCompletionWithAlert: @escaping CompletionWithAlert) {
        apiService.createAttachment(fileUrl: url,
                                    messageID: messageID,
                                    encrypt: isAttachmentsEncrypted)
        { (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(let value):
                    if let attachment = value as? Attachment {
                        onCompletionWithAttachment(attachment)
                    } else {
                        onCompletionWithAttachment(nil)
                    }
                case .failure(let error):
                    let params = AlertKitParams(
                        title: Strings.AppError.error.localized,
                        message: error.localizedDescription,
                        cancelButton: Strings.Button.closeButton.localized
                    )
                    onCompletionWithAlert(params, false)
                }
            }
        }
    }
    
    func deleteAttachment(withId id: String,
                          onCompletion: @escaping (() -> Void),
                          onCompletionWithAlert: @escaping CompletionWithAlert) {
        apiService.deleteAttachment(attachmentID: id) { (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(_):
                    onCompletion()
                case .failure(let error):
                    let params = AlertKitParams(
                        title: Strings.AppError.error.localized,
                        message: error.localizedDescription,
                        cancelButton: Strings.Button.closeButton.localized
                    )
                    onCompletionWithAlert(params, false)
                }
            }
        }
    }
    
    func loadAttachFile(url: String,
                        encrypted: Bool,
                        onCompletion: @escaping ((URL, Bool) -> Void),
                        onCompletionWithAlert: @escaping CompletionWithAlert) {
        apiService.loadAttachFile(url: url) { (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(let value):
                    if let savedFileUrl = value as? URL {
                        onCompletion(savedFileUrl, encrypted)
                    } else {
                        let params = AlertKitParams(
                            title: Strings.AppError.unknownError.localized,
                            message: Strings.AppError.error.localized,
                            cancelButton: Strings.Button.closeButton.localized
                        )
                        onCompletionWithAlert(params, false)
                    }
                case .failure(let error):
                    let params = AlertKitParams(
                        title: Strings.AppError.fileDownloadError.localized,
                        message: error.localizedDescription,
                        cancelButton: Strings.Button.closeButton.localized
                    )
                    onCompletionWithAlert(params, false)
                }
            }
        }
    }
    
    func deleteDraft(withMessageId messageId: String,
                     onCompletion: @escaping ((Bool) -> Void),
                     onCompletionWithAlert: @escaping CompletionWithAlert) {
        let folder = MessagesFoldersName.trash.rawValue
        
        apiService.updateMessages(messageID: "",
                                  messagesIDIn: messageId,
                                  folder: folder,
                                  starred: false,
                                  read: false,
                                  updateFolder: true,
                                  updateStarred: false,
                                  updateRead: false)
        { (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(_):
                    onCompletion(true)
                case .failure(let error):
                    let params = AlertKitParams(
                        title: Strings.AppError.error.localized,
                        message: error.localizedDescription,
                        cancelButton: Strings.Button.closeButton.localized
                    )
                    onCompletionWithAlert(params, false)
                }
            }
        }
    }
    
    func saveDraftMessage(messageID: String,
                          messageContent: String,
                          encryptionObject: [String: String],
                          subject: String,
                          send: Bool,
                          recieversList: [[String]],
                          encrypted: Bool,
                          selfDestructionDate: String,
                          delayedDeliveryDate: String,
                          deadManDate: String,
                          onCompletion: @escaping (() -> Void),
                          onCompletionWithAlert: @escaping CompletionWithAlert) {
        apiService.saveDraftMesssage(messageID: messageID,
                                     messageContent: messageContent,
                                     subject: subject,
                                     recieversList: recieversList,
                                     folder: MessagesFoldersName.draft.rawValue,
                                     encryptionObject: encryptionObject,
                                     encrypted: encrypted,
                                     selfDestructionDate: selfDestructionDate,
                                     delayedDeliveryDate: delayedDeliveryDate,
                                     deadManDate: deadManDate)
        { (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(_):
                    NotificationCenter.default.post(name: .updateInboxMessagesNotificationID,
                                                    object: true, userInfo: nil)
                    onCompletion()
                case .failure(let error):
                    DPrint("Draft Error: \(error.localizedDescription)")
                    let params = AlertKitParams(
                        title: Strings.AppError.error.localized,
                        message: error.localizedDescription,
                        cancelButton: Strings.Button.closeButton.localized
                    )
                    onCompletionWithAlert(params, false)
                }
            }
        }
    }
    
    func createDraftMessage(parentID: String,
                            content: String,
                            subject: String,
                            recievers: [[String]],
                            folder: String,
                            mailboxID: Int,
                            send: Bool,
                            encrypted: Bool,
                            encryptionObject: [String: String],
                            attachments: [[String: String]],
                            onCompletion: @escaping CompletionWithMessage,
                            onCompletionWithAlert: @escaping CompletionWithAlert) {
        DispatchQueue.global(qos: .background).async {
            self.apiService.createMessage(parentID: parentID,
                                          content: content,
                                          subject: subject,
                                          recieversList: recievers,
                                          folder: folder, mailboxID: mailboxID,
                                          send: send,
                                          encrypted: encrypted,
                                          encryptionObject: encryptionObject,
                                          attachments: attachments)
            { (result) in
                DispatchQueue.main.async {
                    switch(result) {
                    case .success(let value):
                        onCompletion(value as? EmailMessage)
                    case .failure(let error):
                        let params = AlertKitParams(
                            title: Strings.AppError.error.localized,
                            message: error.localizedDescription,
                            cancelButton: Strings.Button.closeButton.localized
                        )
                        onCompletionWithAlert(params, true)
                    }
                }
            }
        }
    }
    
    func createDraftWithParent(message: EmailMessage,
                               content: String,
                               recievers: [[String]],
                               mailboxID: Int,
                               onCompletion: @escaping CompletionWithMessage,
                               onCompletionWithAlert: @escaping CompletionWithAlert) {
        
        var encryptionObjectDictionary = [String: String]()
        
        if let encryptionObject = message.encryption {
            encryptionObjectDictionary = encryptionObject.toDictionary()
        }
        
        createDraftMessage(parentID: message.messsageID?.description ?? "",
                           content: content,
                           subject: message.subject ?? "",
                           recievers: recievers,
                           folder: MessagesFoldersName.draft.rawValue,
                           mailboxID: mailboxID,
                           send: false,
                           encrypted: message.isEncrypted ?? false,
                           encryptionObject: encryptionObjectDictionary,
                           attachments: message.attachments?.map({ $0.toDictionary() }) ?? [],
                           onCompletion: onCompletion, onCompletionWithAlert: onCompletionWithAlert)
    }
    
    func fetchContacts(_ onCompletion: @escaping (([Contact]) -> Void)) {
        apiService.userContacts(fetchAll: true, offset: 0, silent: true) { (result) in
            DispatchQueue.main.async {
                switch(result) {
                case .success(let value):
                    if let contactsList = value as? ContactsList,
                        let contacts = contactsList.contactsList {
                        onCompletion(contacts)
                    } else {
                        onCompletion([])
                    }
                case .failure(_):
                    onCompletion([])
                }
            }
        }
    }
    
    func publicKeysFor(userEmailsArray: [String],
                       completion: @escaping (_ keys: EmailsKeys?) -> Void,
                       onCompletionWithAlert: @escaping CompletionWithAlert) {
        
        apiService.publicKeyFor(userEmailsArray: userEmailsArray) { (result) in
            switch(result) {
            case .success(let value):
                if let responseDictionary = value as? [String: Any] {
                    var emailsKeys = EmailsKeys(dict: responseDictionary)
                    if emailsKeys.encrypt {
                        DispatchQueue.global().sync {
                            for emailKey in emailsKeys.keys {
                                if let userPublicKey = UtilityManager
                                    .shared
                                    .pgpService
                                    .readPGPKeysFromString(key: emailKey.publicKey)?.first {
                                    emailsKeys.updatePGPkeys(by: userPublicKey)
                                }
                            }
                            
                            DispatchQueue.main.async {
                                completion(emailsKeys)
                            }
                        }
                    } else {
                        completion(emailsKeys)
                    }
                } else {
                    completion(nil)
                }
            case .failure(let error):
                let params = AlertKitParams(
                    title: Strings.AppError.error.localized,
                    message: error.localizedDescription,
                    cancelButton: Strings.Button.closeButton.localized
                )
                completion(nil)
                onCompletionWithAlert(params, false)
            }
        }
    }
}
