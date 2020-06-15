//
//  ChildMessageExpandedTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 19.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Utility
import Networking

protocol ChildMessageExxpandedTableViewCellDelegate {
    func reloadCell(at index: Int)
}

class ChildMessageExpandedTableViewCell: UITableViewCell {
    
    var parentController : ViewInboxEmailDataSource?
    
    @IBOutlet weak var senderLabel     : UILabel!
    @IBOutlet weak var recieverLabel   : UILabel!
    @IBOutlet weak var dateLabel       : UILabel!
    @IBOutlet weak var detailsButton   : UIButton!
    
    @IBOutlet var fromToBarTextView    : UITextView!
    @IBOutlet weak var contentsWebView: WKWebView!
    
    @IBOutlet weak var deleteLabel             : UILabel!
    @IBOutlet weak var leftLabel               : UILabel!
     
    @IBOutlet weak var timerlabelsView         : UIView!
    @IBOutlet weak var leftlabelView           : UIView!
    @IBOutlet weak var rightlabelView          : UIView!
    
    @IBOutlet var timerlabelsViewWidthConstraint        : NSLayoutConstraint!
    @IBOutlet var leftlabelViewWidthConstraint          : NSLayoutConstraint!
    @IBOutlet var rightlabelViewWidthConstraint         : NSLayoutConstraint!
    
    @IBOutlet var fromToViewHeightConstraint        : NSLayoutConstraint!
    @IBOutlet var fromToBarTextViewHeightConstraint : NSLayoutConstraint!
    
    @IBOutlet weak var contentWebViewHeightConstraint: NSLayoutConstraint!
    
    var showDetails : Bool = false
    //var showContent : Bool = false
    var index : Int = 0
    
    var delegate: ChildMessageExxpandedTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(message: EmailMessage, contentMessage: String, showDetails: Bool, index: Int, delegate: ChildMessageExxpandedTableViewCellDelegate) {
        
        self.showDetails = showDetails     
        self.index = index
        self.delegate = delegate
        
        if let senderName = message.sender_display {
            senderLabel.text = senderName
        }else if let senderEmail = message.sender {
            senderLabel.text = senderEmail
        }
                
        var toEmailsArray : Array<String> = []
        
        if let recieversArray = message.receivers {
            toEmailsArray = recieversArray as! Array<String>
        }
        
        let toText = self.parentController?.formatterService!.formatToString(toEmailsArray: toEmailsArray)
        self.recieverLabel.text = toText
        
        if let createdDate = message.createdAt {            
            if  let date = parentController?.formatterService!.formatStringToDate(date: createdDate) {
                dateLabel.text = parentController?.formatterService!.formatCreationDate(date: date, short: false, useFullDate: true)
            }
        }
        
        self.setupFromToHeaderHeight(message: message)
        
        self.setupDetailsButton()
        
        self.setupMessageContentWebView(messageContent: contentMessage)
        
        self.setupPropertyLabel(message: message)
    }
    
    func setupPropertyLabel(message: EmailMessage) {
          
        leftlabelView.isHidden = true
          
        if let delayedDelivery = message.delayedDelivery {
            leftlabelView.isHidden = false
            leftlabelView.backgroundColor = k_greenColor
            if  let date = parentController?.formatterService!.formatDestructionTimeStringToDate(date: delayedDelivery) {
                leftLabel.attributedText = date.timeCountForDelivery(short: false)
            } else {
                if let date = parentController?.formatterService!.formatDestructionTimeStringToDateTest(date: delayedDelivery) {
                    leftLabel.attributedText = date.timeCountForDelivery(short: false)
                } else {
                    leftLabel.attributedText = NSAttributedString(string: "Error")
                }
            }
        }
          
        if let deadManDuration = message.deadManDuration {
            leftlabelView.isHidden = false
            leftlabelView.backgroundColor = k_redColor
            if  let date = parentController?.formatterService!.formatDeadManDateString(duration: deadManDuration, short: false) {
                leftLabel.attributedText = date
            } else {
                leftLabel.attributedText = NSAttributedString(string: "Error")
            }
        }
    
        if let destructionDate = message.destructDay {
            rightlabelView.isHidden = false
            rightlabelView.backgroundColor = k_orangeColor
            if  let date = parentController?.formatterService!.formatDestructionTimeStringToDate(date: destructionDate) {
                deleteLabel.attributedText = date.timeCountForDestruct(short: false)
            } else {
                //print("erorr formatting destructionDate:", destructionDate)
                if let date = parentController?.formatterService!.formatDestructionTimeStringToDateTest(date: destructionDate) {
                    print("new format date:", date)
                    deleteLabel.attributedText = date.timeCountForDestruct(short: false)
                } else {
                    deleteLabel.attributedText = NSAttributedString(string: "Error")
                }
            }
        } else {
            rightlabelView.isHidden = true
        }
                  
        leftlabelViewWidthConstraint.constant = k_deleteLabelWidth
        rightlabelViewWidthConstraint.constant = k_deleteLabelWidth
                
        if leftlabelView.isHidden {
            leftlabelViewWidthConstraint.constant = 0.0
        }

        if rightlabelView.isHidden {
            rightlabelViewWidthConstraint.constant = 0.0
        }
                
        timerlabelsViewWidthConstraint.constant = leftlabelViewWidthConstraint.constant + rightlabelViewWidthConstraint.constant
          
        self.layoutIfNeeded()
    }
    
    func setupFromToHeaderHeight(message: EmailMessage) {
        
        let fromName: String = ""
        var fromEmail: String = ""
        let toNamesArray : Array<String> = []
        var toEmailsArray : Array<String> = []
        var ccArray : Array<String> = []
        var bccArray : Array<String> = []
        
        if let sender = message.sender {
            fromEmail = sender
        }
        
        if let recieversArray = message.receivers {
            toEmailsArray = recieversArray as! Array<String>
        }
        
        if let carbonCopyArray = message.cc {
            ccArray = carbonCopyArray as! Array<String>
        }
        
        if let bcarbonCopyArray = message.bcc {
            bccArray = bcarbonCopyArray as! Array<String>
        }
         
        let fromToText = parentController?.formatterService!.formatFromToString(fromName: fromName, fromEmail: fromEmail, toNamesArray: toNamesArray, toEmailsArray: toEmailsArray, ccArray: ccArray, bccArray: bccArray)
        
        let fromToAttributtedString = parentController?.formatterService!.formatFromToAttributedString(fromName: fromName, fromToText: fromToText!, toNamesArray: toNamesArray, toEmailsArray: toEmailsArray, ccArray: ccArray, bccArray: bccArray)
        
        self.fromToBarTextView.contentInset = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        self.fromToBarTextView.attributedText = fromToAttributtedString
        
        let numberOfLines = fromToText?.numberOfLines()
        //print("numberOfLines:", numberOfLines as Any)
        
        var fromToViewHeight = k_lineHeightForFromToText * CGFloat(numberOfLines!)
        
        if fromToViewHeight < k_fromToViewMinHeight {
            fromToViewHeight = k_fromToViewMinHeight
        } else {
            fromToViewHeight = (k_lineHeightForFromToText * CGFloat(numberOfLines!))  + k_InsetsForFromTo
        }
        
        //self.fromToViewHeightConstraint.constant = fromToViewHeight       
        
        if self.showDetails {
            self.fromToViewHeightConstraint.constant = fromToViewHeight
        } else {
            self.fromToViewHeightConstraint.constant = 0.0
        }
        
        self.fromToBarTextViewHeightConstraint.constant = self.fromToViewHeightConstraint.constant
        
        self.layoutIfNeeded()
    }
    
    func setupDetailsButton() {

        var text : String = ""

        if self.showDetails {
            text = "hideDetails".localized()
        } else {
            text = "viewDetails".localized()
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 14.0)!,
            .foregroundColor: k_blueColor,            
            .kern: 0.0,
            .paragraphStyle: paragraph
            ])
        
        _ = attributedString.setUnderline(textToFind: text)
        
        self.detailsButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    func setupMessageContentWebView(messageContent: String) {
        contentsWebView.navigationDelegate = self
        contentsWebView.loadHTMLString("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />" + messageContent.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: ""), baseURL: nil)
    }
    
    //MARK: - IBActions
    
    @IBAction func detailsButtonPressed(_ sender: AnyObject) {
        
        self.showDetails = !self.showDetails
        
        self.parentController?.showDetailMessagesArray[self.index] = self.showDetails
        self.parentController?.reloadData(scrollToLastMessage: false)
    }
}

extension ChildMessageExpandedTableViewCell: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.contentsWebView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.contentsWebView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    self.contentWebViewHeightConstraint.constant = height as! CGFloat
                    self.delegate?.reloadCell(at: self.index)
                })
            }

            })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
                let host = url.host, !host.hasPrefix("www.google.com"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                print(url)
                print("Redirected to browser. No need to open it locally")
                decisionHandler(.cancel)
            } else {
                print("Open it locally")
                decisionHandler(.allow)
            }
        } else {
            print("not a user click")
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("web view loading failed: \(error.localizedDescription)")
    }
}
