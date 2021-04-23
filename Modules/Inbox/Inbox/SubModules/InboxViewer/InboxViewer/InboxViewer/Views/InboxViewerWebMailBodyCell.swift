import Foundation
import UIKit
import Utility
import WebKit

public extension WKWebView {
    private var blockRules: String { """
          [{
             "trigger": {
                 "url-filter": ".*",
                 "resource-type": ["image"]
             },
             "action": {
                 "type": "block"
             }
         }]
      """
    }
    
    // Block External Images
    func blockExternalImages() {
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: "ContentBlockingRules",
            encodedContentRuleList: blockRules) { (contentRuleList, error) in
            
            if let _ = error {
                return
            }
            
            let configuration = self.configuration
            configuration.userContentController.add(contentRuleList!)
        }
    }
}

public final class InboxViewerWebMailBodyCell: UITableViewCell, Cellable {
    
    // MARK: IBOutlets
    @IBOutlet weak var webViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: Properties
    var thresholdHeight: CGFloat {
        return 200.0
    }
    
    var onHeightChange: (() -> Void)?
    private var fontMultiplier = "300"
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.tintColor = AppStyle.Colors.loaderColor.color
        activity.hidesWhenStopped = true
        return activity
    }()
    
    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .systemBackground
        setupWebView()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Setup UI
    private func setupWebView() {

        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        webViewHeightConstraint.constant = thresholdHeight
        webView.contentMode = .center
        onHeightChange?()
    }

    // MARK: - Configuration
    public func configure(with model: Modelable) {
        guard let model = model as? TextMail else {
            fatalError("Couldn't Find TextMail")
        }
        
        addSubview(activityIndicatorView)
        
        activityIndicatorView.snp.makeConstraints { (maker) in
            maker.center.centerX.centerY.equalToSuperview()
        }
        
        bringSubviewToFront(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
        
        if model.shouldBlockExternalImages {
            webView.blockExternalImages()
        }
        
        activityIndicatorView.startAnimating()
        
        if model.content.contains("!DOCTYPE html PUBLIC") {
            fontMultiplier = "100"
        }else {
            fontMultiplier = "300"
        }
        
        if model.content.contains("color:") {
            webView.loadHTMLString(model.content.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: ""), baseURL: nil)
        } else {
            webView.loadHTMLString("<font color= \(traitCollection.userInterfaceStyle == .dark ? "\'white\'" : "\'black\'")\">" + model.content.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "") + "</div>", baseURL: nil)
        }
    }
    
    private func applyJS() {
        var scriptContent = "var meta = document.createElement('meta');"
        scriptContent += "meta.name='viewport';"
        scriptContent += "meta.content='width=device-width';"
        scriptContent += "document.getElementsByTagName('head')[0].appendChild(meta);"
        scriptContent += "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(150)%'"
        webView.evaluateJavaScript(scriptContent, completionHandler: nil)
    }
}

// MARK: - WKUIDelegate
extension InboxViewerWebMailBodyCell: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
        let js = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(fontMultiplier)%'"//dual size
        webView.evaluateJavaScript(js, completionHandler: nil)

        self.webView.evaluateJavaScript("document.readyState", completionHandler: { [weak self] (complete, error) in
            if complete != nil {
                self?.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    if let height = height as? CGFloat {
                        self?.webViewHeightConstraint.constant = height
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self?.onHeightChange?()
                        }
                    }
                })
            }
        })
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
                let host = url.host, !host.hasPrefix("www.google.com"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                DPrint(url)
                DPrint("Redirected to browser. No need to open it locally")
                decisionHandler(.cancel)
            } else {
                DPrint("Open it locally")
                decisionHandler(.allow)
            }
        } else {
            DPrint("not a user click")
            decisionHandler(.allow)
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DPrint("web view loading failed: \(error.localizedDescription)")
    }
}
