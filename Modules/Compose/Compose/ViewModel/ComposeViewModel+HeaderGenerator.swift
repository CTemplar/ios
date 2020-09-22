import Utility
import Networking

extension ComposeViewModel {
    func generateHeader(message: EmailMessage, answerMode: AnswerMessageMode) -> NSAttributedString {
        var attributedString = NSAttributedString()
        
        switch answerMode {
        case .newMessage: break
        case .reply:
            attributedString = generateReplyHeader(message: message)
        case .replyAll:
            attributedString = generateReplyHeader(message: message)
        case .forward:
            attributedString = generateForwardHeader(message: message, subject: email.subject ?? "")
        }
        return attributedString
    }
    
    func generateHtmlHeader(message: EmailMessage, answerMode: AnswerMessageMode) -> String {
        var string = ""
        switch answerMode {
        case .newMessage: break
        case .reply:
            string = generateHtmlReplyHeader(message: message)
        case .replyAll:
            string = generateHtmlReplyHeader(message: message)
        case .forward:
            string = generateHtmlForwardHeader(message: message, subject: email.subject ?? "")
        }
        return string
    }
    
    func generateReplyHeader(message: EmailMessage) -> NSAttributedString {
        var replyHeader = ""
        
        if let sentAtDate = message.updated { //message.sentAt
            
            if  let date = formatterService.formatStringToDate(date: sentAtDate) {
                let formattedDate = formatterService.formatReplyDate(date: date)
                let formattedTime = formatterService.formatDateToStringTimeFull(date: date)
                
                replyHeader = "\n\n" + "replyOn".localized() + replyHeader + formattedDate + Strings.Compose.atTime.localized + formattedTime + "\n"
            }
        }
        
        if let sender = message.sender {
            replyHeader = replyHeader + "<" + sender + "> " + Strings.Compose.wroteBy.localized + "\n\n"
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
        if let sentAtDate = message.updated {
            if let date = formatterService.formatStringToDate(date: sentAtDate) {
                let formattedDate = formatterService.formatReplyDate(date: date)
                let formattedTime = formatterService.formatDateToStringTimeFull(date: date)
                replyHeader = """
                    <div><br></div><div>--------Original Message---------</div><div>
                    \(Strings.Compose.replyOn.localized) \(formattedDate)
                    \(Strings.Compose.atTime.localized) \(formattedTime)
                    """
            }
        }
        
        if let sender = message.sender {
            replyHeader = replyHeader + "<p>\"" + sender + "\" " + Strings.Compose.wroteBy.localized + "</p><br>"
        }
        
        return replyHeader
    }
    
    func generateForwardHeader(message: EmailMessage, subject: String) -> NSAttributedString {
        /*
         ---------- Forwarded message ----------
         
         From: <atif1@dev.ctemplar.com>
         
         Date: Dec 14, 2018, 11:10:23 AM
         
         Subject: Self-destructing Msg
         
         To: <dmitry3@dev.ctemplar.com>
         */
        var forwardHeader = ""
        
        forwardHeader = forwardHeader + Strings.Compose.forwardLine.localized
        
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
        
        if let recieversArray = message.receivers as? [String]  {
            for email in recieversArray {
                forwardHeader = forwardHeader + Strings.Compose.emailToPrefix.localized + "<" + email + "> "
            }
        }
        
        forwardHeader = forwardHeader + "\n\n"
        
        let font = AppStyle.CustomFontStyle.Regular.font(withSize: 14.0)!

        let attributedString = NSMutableAttributedString(string: forwardHeader, attributes: [
            .font: font,
            .foregroundColor: k_actionMessageColor,
            .kern: 0.0
        ])
        
        return attributedString
    }
    
    func generateHtmlForwardHeader(message: EmailMessage, subject: String) -> String{
        var forwardHeader : String = "<br>"
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
        
        forwardHeader = forwardHeader + "<p>" + Strings.Compose.subject.localized.replacingOccurrences(of: ": ", with: "") + subject + "</p>"
        
        if let recieversArray = message.receivers as? [String]  {
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
