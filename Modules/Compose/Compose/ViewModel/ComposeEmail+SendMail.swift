import Utility
import Networking

extension ComposeViewModel {
    func sendEncryptedEmailForCtemplarUser(publicKeys: [PGPKey]) {
        guard let messsageID = email.messsageID?.description else {
            DispatchQueue.main.async {
                Loader.stop()
            }
            return
        }
        
        var messageContent = getMailContent()
        
        if !messageContent.contains("BEGIN PGP") {
            messageContent = encryptMessage(publicKeys: publicKeys, message: messageContent)
        }
        
        var subject = email.subject ?? ""
        
        let subjectEncrypted = user.settings.isSubjectEncrypted ?? false
        
        if subjectEncrypted {
            subject = encryptMessage(publicKeys: publicKeys, message: subject)
        }
        
        let attachments: [[String: String]] = email.attachments?.map({ $0.toDictionary() }) ?? []
        
        let message = Message(messageID: messsageID,
                              encryptedMessage: messageContent,
                              encryptionObject: [:],
                              subject: subject,
                              send: true,
                              recieversList: receiversList(),
                              encrypted: true,
                              subjectEncrypted: subjectEncrypted,
                              attachments: attachments,
                              selfDestructionDate: email.destructDay ?? "",
                              delayedDeliveryDate: email.delayedDelivery ?? "",
                              deadManDate: email.deadManDuration?.description ?? "",
                              mailboxId: mailboxId,
                              sender: email.sender ?? "")
        
        fetcher.updateSendingMessage(withMessageObject: message,
                                     onCompletion:
            { (_) in
                Loader.stop()
        }, onCompletionWithBanner: { (bannerText) in
            NotificationCenter.default.post(name: .mailSentNotificationID, object: bannerText)
        }) { (params, _) in
            Loader.stop()
            NotificationCenter.default.post(name: .mailSentErrorNotificationID, object: params)
        }
    }
    
    func sendEmailForNonCtemplarUser(messageID: String, attachments: [Attachment]) {
        guard let userName = email.messsageID?.description else {
            DispatchQueue.main.async {
                Loader.stop()
            }
            return
        }
        
        var messageContent = getMailContent()
        
        if messageContent.contains("BEGIN PGP"), let decryptedContent = decryptedMailContent() {
            messageContent = decryptedContent
        }
        
        let attachments: [[String: String]] = email.attachments?.map({ $0.toDictionary() }) ?? []
        
        if menuCellVM?.selectedMenus.contains(.mailEncryption) == true {
            if let encryptionObject = email.encryption {
                let nonCtemplarPGPKey = pgpService.generatePGPKey(userName: userName, password: emailPassword)
                
                let encryptionObjectDictionary = setPGPKeysForEncryptionObject(object: encryptionObject, pgpKey: nonCtemplarPGPKey)
                
                var pgpKeys: [PGPKey] = pgpService.getStoredPGPKeys() ?? []
                
                pgpKeys.append(nonCtemplarPGPKey)
                
                messageContent = encryptMessage(publicKeys: pgpKeys, message: messageContent)
                
                let message = Message(messageID: userName,
                                      encryptedMessage: messageContent,
                                      encryptionObject: encryptionObjectDictionary,
                                      subject: email.subject ?? "",
                                      send: true,
                                      recieversList: receiversList(),
                                      encrypted: true,
                                      subjectEncrypted: false,
                                      attachments: attachments,
                                      selfDestructionDate: email.destructDay ?? "",
                                      delayedDeliveryDate: email.delayedDelivery ?? "",
                                      deadManDate: email.deadManDuration?.description ?? "",
                                      mailboxId: mailboxId,
                                      sender: email.sender ?? "")
                
                fetcher.updateSendingMessage(withMessageObject: message,
                                             onCompletion:
                    { (_) in
                        Loader.stop()
                }, onCompletionWithBanner: { (bannerText) in
                    NotificationCenter.default.post(name: .mailSentNotificationID, object: bannerText)
                }) { (params, _) in
                    Loader.stop()
                    NotificationCenter.default.post(name: .mailSentErrorNotificationID, object: params)
                }
            }
        } else {
            let message = Message(messageID: userName,
                                  encryptedMessage: messageContent,
                                  encryptionObject: [:],
                                  subject: email.subject ?? "",
                                  send: true,
                                  recieversList: receiversList(),
                                  encrypted: false,
                                  subjectEncrypted: false,
                                  attachments: attachments,
                                  selfDestructionDate: email.destructDay ?? "",
                                  delayedDeliveryDate: email.delayedDelivery ?? "",
                                  deadManDate: email.deadManDuration?.description ?? "",
                                  mailboxId: mailboxId,
                                  sender: email.sender ?? "")
            fetcher.updateSendingMessage(withMessageObject: message,
                                         onCompletion:
                { (_) in
                    Loader.stop()
            }, onCompletionWithBanner: { (bannerText) in
                NotificationCenter.default.post(name: .mailSentNotificationID, object: bannerText)
            }) { (params, _) in
                Loader.stop()
                NotificationCenter.default.post(name: .mailSentErrorNotificationID, object: params)
            }
        }
    }
    
    func prepareEmailForNonCtemplarUser() {
        guard let messageId = email.messsageID else {
            return
        }
        
        if menuCellVM?.selectedMenus.contains(.mailEncryption) == true {
            let userName = messageId.description
            let nonCtemplarPGPKey = pgpService.generatePGPKey(userName: userName, password: emailPassword)
            var pgpKeys: [PGPKey] = []
            
            if let userKeys = pgpService.getStoredPGPKeys(), !userKeys.isEmpty {
                pgpKeys = userKeys
            }
            
            pgpKeys.append(nonCtemplarPGPKey)
            
            updateAttachmentsForNonCtemplarUsers(attachments: email.attachments ?? [],
                                                 index: 0,
                                                 publicKeys: pgpKeys,
                                                 messageID: messageId)
        } else {
            updateAttachmentsForNonCtemplarUsers(attachments: email.attachments ?? [],
                                                 index: 0,
                                                 publicKeys: [],
                                                 messageID: messageId)
        }
    }
}
