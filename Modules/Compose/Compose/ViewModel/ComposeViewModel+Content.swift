import Utility
import Networking

extension ComposeViewModel {
    func initialiseEmailContent() -> String {
        var messageContent = getMailContent()
        
        if messageContent.contains("BEGIN PGP"), let decryptedContent = decryptedMailContent() {
            messageContent = decryptedContent
        }
        
        var contentString = ""
        
        if !messageContent.isEmpty {
            let replyHeader = generateHtmlHeader(message: email, answerMode: answerMode)
            
            contentString.append(replyHeader)
            contentString.append("<div><div class='originalblock'>")
            contentString.append(messageContent)
            contentString.append("</div></div>")
            
            if currentSignature?.isEmpty == false {
                contentString.append("<br><br>\(currentSignature!)")
            }
        } else {
            guard let signature = currentSignature else {
                return contentString
            }
            contentString.append("<br><br>\(signature)")
        }
        return contentString
    }
    
    func getMailContent() -> String {
//        var messageContent = email.content ?? ""
//        let signature = currentSignature ?? ""
//
//        if let range = messageContent.range(of: signature) {
//            messageContent = messageContent.replacingCharacters(in: range, with: "")
//            messageContent.append("<br>\(signature)")
//        }
//
//        if messageContent == Strings.Compose.composeEmail.localized {
//            messageContent = ""
//        }
//        return messageContent
        return email.content ?? ""
    }
    
    func decryptedMailContent() -> String? {
        if let content = email.content {
            let message = pgpService.decryptMessage(encryptedContet: content)
            if message == "#D_FAILED_ERROR#" {
                return nil
            }
            return message
        }
        return nil
    }
}
