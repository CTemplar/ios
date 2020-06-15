import Foundation
import UIKit

public extension String {
     func localized() -> String {
         return NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: "", comment: "")
     }
     
     func localized(lang: String) -> String {
         let path = Bundle.main.path(forResource: lang, ofType: "lproj")
         let bundle = Bundle(path: path!)
         return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
     }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    var removeHTMLTag: String {
        guard let data = self.data(using: .utf8) else {
            return self
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        
        return attributedString.string.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression)
    }
    
    func numberOfLines() -> Int {
        var numberOfLines = 0
        self.enumerateLines { (str, _) in
            numberOfLines += 1
        }
        return numberOfLines
    }
}
