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
        
        messageContent = messageContent.replacingOccurrences(of: "\n", with: "<br>")
        
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
            Loader.stop()
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
                    Loader.stop()
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
                Loader.stop()
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
// MARK: - Attachment Helpers
extension ComposeViewModel {
    
    private func getAttachmentData(from attachment: Attachment) -> (data: Data?, url: URL?) {
        if let contentURL = attachment.contentUrl, let fileUrl = URL(string: contentURL) {
            return (data: try? Data(contentsOf: fileUrl), url: fileUrl)
        }
        
        if let localFileURL = attachment.localUrl {
            let fileUrl = URL(fileURLWithPath: localFileURL)
            return (data: try? Data(contentsOf: fileUrl), url: fileUrl)
        }

        return (data: nil, url: nil)
    }
    
    func updateAttachments(publicKeys: [PGPKey], messageID: Int) {
        var attachmentsCount = email.attachments?.count ?? 0
        
        for attachment in email.attachments ?? [] {
            let response = getAttachmentData(from: attachment)
            
            guard let fileData = response.data,
                let fileURL = response.url,
                let attachmentId = attachment.attachmentID else {
                    Loader.stop()
                    let params = AlertKitParams(
                        title: Strings.AppError.error.localized,
                        message: Strings.AppError.unknownError.localized,
                        cancelButton: Strings.Button.closeButton.localized
                    )
                    NotificationCenter.default.post(name: .mailSentErrorNotificationID, object: params)
                    return
            }
            
            if user.settings.isAttachmentsEncrypted == true {
                if !publicKeys.isEmpty {
                    guard let encryptedfileData = pgpService.encryptAsData(data: fileData, keys: publicKeys) else {
                        Loader.stop()
                        let params = AlertKitParams(
                            title: Strings.AppError.error.localized,
                            message: Strings.AppError.unknownError.localized,
                            cancelButton: Strings.Button.closeButton.localized
                        )
                        NotificationCenter.default.post(name: .mailSentErrorNotificationID, object: params)
                        return
                    }
                    
                    // Send to CTemplar User
                    NetworkManager
                        .shared
                        .apiService
                        .updateAttachment(attachmentID: attachmentId.description,
                                          fileUrl: fileURL,
                                          fileData: encryptedfileData,
                                          messageID: messageID,
                                          encrypt: true) { (_) in
                                            attachmentsCount -= 1
                                            if attachmentsCount == 0 {
                                                self.sendEncryptedEmailForCtemplarUser(publicKeys: publicKeys)
                                            }
                    }
                } else {
                    // Send to Non-CTemplar User
                    NetworkManager
                        .shared
                        .apiService
                        .updateAttachment(attachmentID: attachmentId.description,
                                          fileUrl: fileURL,
                                          fileData: fileData,
                                          messageID: messageID,
                                          encrypt: false)
                        { (_) in
                            attachmentsCount -=  1
                            if attachmentsCount == 0 {
                                self.sendEmailForNonCtemplarUser(messageID: messageID.description,
                                                                 attachments: [attachment])
                            }
                    }
                }
            } else {
                // Send to CTemplar User
                NetworkManager
                    .shared
                    .apiService
                    .updateAttachment(attachmentID: attachmentId.description,
                                      fileUrl: fileURL,
                                      fileData: fileData,
                                      messageID: messageID,
                                      encrypt: false)
                    { (_) in
                        attachmentsCount -= 1
                        if attachmentsCount == 0 {
                            self.sendEncryptedEmailForCtemplarUser(publicKeys: publicKeys)
                        }
                }
            }
        }
    }
    
    func updateAttachmentsForNonCtemplarUsers(attachments: [Attachment],
                                              index: Int,
                                              publicKeys: [PGPKey],
                                              messageID: Int) {
        if index >= attachments.count {
            sendEmailForNonCtemplarUser(messageID: "\(messageID)", attachments: attachments)
            return
        }
        
        var attachments1 = attachments
        let attachment = attachments1[index]
        
        let isAttachmentEncrypted = user.settings.isAttachmentsEncrypted ?? false
        
        let response = getAttachmentData(from: attachment)
        
        guard let data = response.data, let fileUrl = response.url else {
            Loader.stop()

            let params = AlertKitParams(
                title: Strings.AppError.error.localized,
                message: Strings.AppError.unknownError.localized,
                cancelButton: Strings.Button.closeButton.localized
            )
            NotificationCenter.default.post(name: .mailSentErrorNotificationID, object: params)
            return
        }
        
        let attachID = attachment.attachmentID?.description ?? ""
        
        if !publicKeys.isEmpty {
            if let encryptedfileData = pgpService.encryptAsData(data: data, keys: publicKeys) {
                NetworkManager
                    .shared
                    .apiService
                    .updateAttachment(attachmentID: attachID,
                                      fileUrl: fileUrl,
                                      fileData: encryptedfileData,
                                      messageID: messageID,
                                      encrypt: true,
                                      completionHandler:
                        { (result) in
                            switch result {
                            case .success(let value):
                                if let newAttachment = value as? Attachment {
                                    attachments1[index] = newAttachment
                                }
                                self.updateAttachmentsForNonCtemplarUsers(attachments: attachments1,
                                                                          index: index + 1, publicKeys: publicKeys,
                                                                          messageID: messageID)
                            case .failure(let error):
                                Loader.stop()
                                let params = AlertKitParams(
                                    title: Strings.AppError.error.localized,
                                    message: error.localizedDescription,
                                    cancelButton: Strings.Button.closeButton.localized
                                )
                                NotificationCenter.default.post(name: .mailSentErrorNotificationID, object: params)
                            }
                    })
            }
        } else {
            NetworkManager
                .shared
                .apiService
                .updateAttachment(attachmentID: attachID,
                                  fileUrl: fileUrl,
                                  fileData: data,
                                  messageID: messageID,
                                  encrypt: isAttachmentEncrypted,
                                  completionHandler:
                    { (result) in
                        switch result {
                        case .success(let value):
                            if let newAttachment = value as? Attachment {
                                attachments1[index] = newAttachment
                            }
                            self.updateAttachmentsForNonCtemplarUsers(attachments: attachments1,
                                                                      index: index + 1,
                                                                      publicKeys: publicKeys,
                                                                      messageID: messageID)
                        case .failure(let error):
                            Loader.stop()
                            let params = AlertKitParams(
                                title: Strings.AppError.error.localized,
                                message: error.localizedDescription,
                                cancelButton: Strings.Button.closeButton.localized
                            )
                            NotificationCenter.default.post(name: .mailSentErrorNotificationID, object: params)
                        }
                })
        }
    }
}