import Foundation
import UIKit

public extension NSMutableAttributedString {
     func setAsLink(textToFind: String, linkURL: String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            self.addAttributes(underlineAttribute, range: foundRange)
            return true
        }
        return false
    }
    
    func setUnderline(textToFind: String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            self.addAttributes(underlineAttribute, range: foundRange)
            return true
        }
        return false
    }
    
    func setForgroundColor(textToFind: String, color: UIColor) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.foregroundColor, value: color, range: foundRange)
            return true
        }
        return false
    }
    
    func foundRangeFor(lowercasedString: String, textToFind: String) -> NSRange {
        let lowercasedTextToFind = textToFind.lowercased()
        if let stringRange = lowercasedString.range(of: lowercasedTextToFind) {
            let foundRange = NSRange(stringRange, in: lowercasedString)
            
            if foundRange.location != NSNotFound {
                return foundRange
            }
        }
        
        return NSRange(location: 0, length: 0)
    }
    
    func setBackgroundColor(range: NSRange, color: UIColor) -> Bool {
        if range.location != NSNotFound {
            self.addAttribute(.backgroundColor, value: color, range: range)
            return true
        }
        return false
    }
    
    func setBackgroundColor(textToFind: String, color: UIColor) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.backgroundColor, value: color, range: foundRange)
            return true
        }
        return false
    }
    
    func setFont(textToFind: String, font: UIFont) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.font, value: font, range: foundRange)
            return true
        }
        return false
    }
}
