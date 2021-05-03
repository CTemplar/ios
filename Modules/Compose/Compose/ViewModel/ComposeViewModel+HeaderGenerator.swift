import Utility
import Networking

extension ComposeViewModel {
    func generateHtmlHeader(message: EmailMessage, answerMode: AnswerMessageMode) -> String {
        var string = ""
        switch answerMode {
        case .newMessage, .newMessageWithReceiverEmail: break
        case .reply:
            string = generateHtmlReplyHeader(message: message)
        case .replyAll:
            string = generateHtmlReplyHeader(message: message)
        case .forward:
            var subject = email.subject ?? ""
            if subject.contains("BEGIN PGP"),
               let decryptedContent = decryptedMailContent(from: subject) {
                subject = decryptedContent
            }
            string = generateHtmlForwardHeader(message: message, subject: subject)
        }
        return string
    }
    
    func generateReplyHeader(message: EmailMessage) -> NSAttributedString {
        var replyHeader = ""
        
        func createIterativeReplyHeader(from email: EmailMessage) {
            if let sentAtDate = message.updated { //message.sentAt
                if  let date = formatterService.formatStringToDate(date: sentAtDate) {
                    let formattedDate = formatterService.formatReplyDate(date: date)
                    let formattedTime = formatterService.formatDateToStringTimeFull(date: date)
                    replyHeader = "\n" + Strings.Compose.replyOn.localized + replyHeader + formattedDate + Strings.Compose.atTime.localized + formattedTime + "\n"
                }
            }
            
            if let sender = message.sender {
                replyHeader = replyHeader + "<p>\"" + sender + "\" " + Strings.Compose.wroteBy.localized + "</p>"
            }
        }
        
        if let lastMessage = message.children?.last {
            createIterativeReplyHeader(from: lastMessage)
        } else {
            createIterativeReplyHeader(from: message)
        }
        
        let font = AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)!
        
        let attributedString = NSMutableAttributedString(string: replyHeader, attributes: [
            .font: font,
            .foregroundColor: k_actionMessageColor,
            .kern: 0.0
        ])
        
        return attributedString
    }
    
    func generateHtmlReplyHeader(message: EmailMessage) -> String{
        var replyHeader = ""
        
        func createIterativeReplyHeader(from email: EmailMessage) {
            if let sentAtDate = message.updated {
                if let date = formatterService.formatStringToDate(date: sentAtDate) {
                    let formattedDate = formatterService.formatReplyDate(date: date)
                    let formattedTime = formatterService.formatDateToStringTimeFull(date: date)
                    replyHeader = """
                        <br><div>--------Original Message---------</div>
                        \(Strings.Compose.replyOn.localized) \(formattedDate)
                        \(Strings.Compose.atTime.localized) \(formattedTime)
                        """
                }
            }
            
            if let sender = message.sender {
                replyHeader = replyHeader + " &lt; " + sender + "\"" + " &gt; " + Strings.Compose.wroteBy.localized + "<br>"
            }
            replyHeader = replyHeader.replacingOccurrences(of: "\n", with: "")
        }
        
        if let lastMessage = message.children?.last {
            createIterativeReplyHeader(from: lastMessage)
        } else {
            createIterativeReplyHeader(from: message)
        }
        
        return replyHeader
    }
    
    func generateForwardHeader(message: EmailMessage, subject: String) -> NSAttributedString {
        var forwardHeader = Strings.Compose.forwardLine.localized
        
        func createIterativeForwardHeader(from email: EmailMessage) {
            if let sender = message.sender {
                forwardHeader = "\(forwardHeader)\n\(Strings.Compose.emailFromPrefix.localized)<\(sender)>\n"
            }
            
            if let sentAtDate = message.updated {
                if  let date = formatterService.formatStringToDate(date: sentAtDate) {
                    let formattedDate = formatterService.formatReplyDate(date: date)
                    let formattedTime = formatterService.formatDateToStringTimeFull(date: date)
                    forwardHeader = forwardHeader + Strings.Compose.date.localized + formattedDate + Strings.Compose.atTime.localized + formattedTime + "\n"
                }
            }
            
            forwardHeader = forwardHeader + Strings.Compose.subject.localized + subject + "\n"
            
            if let recieversArray = message.receivers  {
                for email in recieversArray {
                    forwardHeader = forwardHeader + Strings.Compose.emailToPrefix.localized + "<" + email + "> "
                }
            }
            
            forwardHeader = forwardHeader + "\n"
        }
        
        if let lastMessage = message.children?.last {
            createIterativeForwardHeader(from: lastMessage)
        } else {
            createIterativeForwardHeader(from: message)
        }
        
        let font = AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)!

        let attributedString = NSMutableAttributedString(string: forwardHeader, attributes: [
            .font: font,
            .foregroundColor: k_actionMessageColor,
            .kern: 0.0
        ])
        
        return attributedString
    }
    
    func generateHtmlForwardHeader(message: EmailMessage, subject: String) -> String{
        var forwardHeader = "<br>"
        forwardHeader = forwardHeader + "<p>" + Strings.Compose.forwardLine.localized + "</p>"
        
        if let sender = message.sender {
            forwardHeader = forwardHeader + "<p>" + Strings.Compose.emailFromPrefix.localized + "\" " + sender + "\"</p><br>"
        }
        
        if let sentAtDate = message.updated {
            if let date = formatterService.formatStringToDate(date: sentAtDate) {
                let formattedDate = formatterService.formatReplyDate(date: date)
                let formattedTime = formatterService.formatDateToStringTimeFull(date: date)
                forwardHeader = forwardHeader + "<p>" + Strings.Compose.date.localized + formattedDate + Strings.Compose.atTime.localized + formattedTime + "</p>"
            }
        }
        
        forwardHeader = forwardHeader + "<p>" + Strings.Compose.subject.localized + subject + "</p>"
        
        if let recieversArray = message.receivers {
            forwardHeader = forwardHeader + "<p>"
            for email in recieversArray {
                forwardHeader = forwardHeader + Strings.Compose.emailToPrefix.localized + "\"" + email + "\" "
            }
            forwardHeader = forwardHeader + "</p>"
        }
        
        forwardHeader = forwardHeader + "<br><br>"
        
        return forwardHeader
    }
}
