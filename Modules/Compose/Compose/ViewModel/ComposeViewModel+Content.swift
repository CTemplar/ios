import Utility
import Networking

extension ComposeViewModel {
    func initialiseEmailContent() -> String {
        var messageContent = getMailContent(from: parentMail?.children?.last ?? email)
        
        if messageContent.contains("BEGIN PGP"),
           let decryptedContent = decryptedMailContent(from: parentMail?.children?.last ?? email) {
            messageContent = decryptedContent
        }
        
        var contentString = ""
        
        if !messageContent.isEmpty {
            let replyHeader = generateHtmlHeader(message: parentMail?.children?.last ?? email, answerMode: answerMode)
            
            contentString.append(replyHeader)
            contentString.append(messageContent)
            
            if currentSignature?.isEmpty == false {
                contentString.append("<br>\(currentSignature!)")
            }
        } else {
            guard let signature = currentSignature else {
                return contentString
            }
            contentString.append("<br>\(signature)")
        }
        return contentString
    }
    
    func getMailContent(from email: EmailMessage) -> String {
        return email.content ?? ""
    }
    
    func decryptedMailContent(from content: String) -> String? {
        let message = pgpService.decryptMessage(encryptedContet: content)
        if message == "#D_FAILED_ERROR#" {
            return nil
        }
        return message
    }
    
    func decryptedMailContent(from email: EmailMessage) -> String? {
        var message: String?
        DispatchQueue.global(qos: .background).sync {
            if let content = email.content {
                message = pgpService.decryptMessage(encryptedContet: content)
            }
        }
        
        return message
    }
}
