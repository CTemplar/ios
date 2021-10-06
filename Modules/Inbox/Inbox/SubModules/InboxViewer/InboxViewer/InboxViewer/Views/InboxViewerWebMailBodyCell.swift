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
    private var webView: WKWebView?
    
    // MARK: Properties
    var isLoaded = false
    
    var isFromAfterTopCall = false
    
    var thresholdHeight: CGFloat = 200.0
    
    var onHeightChange: (() -> Void)?
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.tintColor = AppStyle.Colors.loaderColor.color
        activity.hidesWhenStopped = true
        return activity
    }()
    
    let viewportScriptString = """
        var meta = document.createElement('meta');
        meta.setAttribute('name', 'viewport');
        meta.setAttribute('content', 'width=device-width');
        meta.setAttribute('content', 'shrink-to-fit=YES');
        meta.setAttribute('initial-scale', '1.0');
        meta.setAttribute('maximum-scale', '1.0');
        meta.setAttribute('minimum-scale', '1.0');
        meta.setAttribute('user-scalable', 'no');
        document.getElementsByTagName('head')[0].appendChild(meta);
    """
    let cssSource = """
        :root {
            //1
            color-scheme: light dark;
                //2
                --h1-color: red;
                --header-bg-clr: green;
                --header-txt-clr: black;
            }
            //3
            @media (prefers-color-scheme: dark) {
            :root {
                color-scheme: light dark;
                --h1-color: #ff8080;
                --header-bg-clr: #80ff80;
                --header-txt-clr: white;
                }
            }
         
        body { }
        //4
        h1 { color: var(--h1-color); }
        .header {
            background-color: var (--header-bg-clr);
            color: var(--header-txt-clr);
        }
        """
    // MARK: - Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .systemBackground
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupWebView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    deinit {
        // webView.scrollView.removeObserver(self, forKeyPath: "contentSize", context: nil)
        if (self.webView != nil) {
            webView?.navigationDelegate = nil
            clearWebView()
        }
    }
    
    // MARK: - Setup UI
    private func setupWebView() {
        // 1 - Make user scripts for injection
        let viewportScript = WKUserScript(source: viewportScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let cssScript = WKUserScript(source: cssSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        // 2 - Initialize a user content controller
        // From docs: "provides a way for JavaScript to post messages and inject user scripts to a web view."
        let controller = WKUserContentController()
        // 3 - Add scripts
        controller.addUserScript(viewportScript)
        // controller.addUserScript(cssScript)
        // 4 - Initialize a configuration and set controller
        let config = WKWebViewConfiguration()
        config.userContentController = controller
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView?.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(webView!)
        
        addConstraints()
        
        webView?.isOpaque = false
        isLoaded = false
        webView?.scrollView.bounces = false
        webView?.backgroundColor = .systemBackground
        webView?.navigationDelegate = nil
        webView?.navigationDelegate = self
        webView?.contentMode = .scaleAspectFit
    }

    private func clearWebView() {
        webView?.removeFromSuperview()
        webView = nil
    }
    
    // MARK: - Configuration
    private func addConstraints() {
        webView?.constraints.forEach({
            webView?.removeConstraint($0)
        })
        
        [
            webView?.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4.0),
            webView?.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 4.0),
            webView?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
            webView?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 4.0),
            webView?.heightAnchor.constraint(equalToConstant: thresholdHeight)
        ].compactMap({ $0 })
        .forEach({
            $0.isActive = true
        })
        
        layoutIfNeeded()
    }
    
    public func configure(with model: Modelable) {
        guard let model = model as? TextMail else {
            fatalError("Couldn't Find TextMail")
        }
        
        addSubview(activityIndicatorView)
        
        activityIndicatorView.snp.makeConstraints { (maker) in
            maker.center.centerX.centerY.equalToSuperview()
        }
        
        bringSubviewToFront(activityIndicatorView)
                        
        clearWebView()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setupWebView()
            
            if model.shouldBlockExternalImages {
                self.webView?.blockExternalImages()
            }
            
            self.activityIndicatorView.startAnimating()
            
            let content = model.content.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
            if model.content.contains("color:") {
                if  model.content.contains("color:black") {
                    if model.content.contains("background-color:black") {
                        let newContent = self.traitCollection.userInterfaceStyle == .dark ? model.content.replacingOccurrences(of: ";color:black", with: ";color:white") : model.content.replacingOccurrences(of: ";color:black", with: ";color:white")
                        self.webView?.loadHTMLString("<font color= \(self.traitCollection.userInterfaceStyle == .dark ? "\'white\'" : "\'black\'")\">" + newContent + "</div>", baseURL: nil)
                       // self.webView?.loadHTMLString(newContent, baseURL: nil)
                    }
                    else {
                        let newContent = self.traitCollection.userInterfaceStyle == .dark ? model.content.replacingOccurrences(of: "color:black", with: "color:white") : model.content
                        self.webView?.loadHTMLString("<font color= \(self.traitCollection.userInterfaceStyle == .dark ? "\'white\'" : "\'black\'")\">" + newContent + "</div>", baseURL: nil)
                       // self.webView?.loadHTMLString(newContent, baseURL: nil)
                    }
                   
                }
                else  if model.content.contains("color:white") {
                    let newContent = self.traitCollection.userInterfaceStyle == .dark ? model.content : model.content.replacingOccurrences(of: "color:white", with: "color:black")
                    self.webView?.loadHTMLString("<font color= \(self.traitCollection.userInterfaceStyle == .dark ? "\'white\'" : "\'black\'")\">" + newContent + "</div>", baseURL: nil)
                  //  self.webView?.loadHTMLString(newContent, baseURL: nil)
                }
                else {
                    self.webView?.loadHTMLString("<font color= \(self.traitCollection.userInterfaceStyle == .dark ? "\'white\'" : "\'black\'")\">" + content + "</div>", baseURL: nil)
                   // self.webView?.loadHTMLString(content, baseURL: nil)
                }
                
            }
             else if model.content.contains("color=") {
                 if model.content.contains("color=\"#000000\"") {
                    let newContent = self.traitCollection.userInterfaceStyle == .dark ? model.content.replacingOccurrences(of: "color=\"#000000\"", with: "color=\"#ffffff\"") : model.content
                     self.webView?.loadHTMLString("<font color= \(self.traitCollection.userInterfaceStyle == .dark ? "\'white\'" : "\'black\'")\">" + newContent + "</div>", baseURL: nil)
                   // self.webView?.loadHTMLString(newContent, baseURL: nil)
                }
                else  if model.content.contains("color=\"#ffffff\"") {
                    let newContent = self.traitCollection.userInterfaceStyle == .dark ? model.content : model.content.replacingOccurrences(of: "color=\"#ffffff\"", with: "color=\"#000000\"")
                    self.webView?.loadHTMLString("<font color= \(self.traitCollection.userInterfaceStyle == .dark ? "\'white\'" : "\'black\'")\">" + newContent + "</div>", baseURL: nil)
                   // self.webView?.loadHTMLString(newContent, baseURL: nil)
                }
                else {
                    self.webView?.loadHTMLString("<font color= \(self.traitCollection.userInterfaceStyle == .dark ? "\'white\'" : "\'black\'")\">" + content + "</div>", baseURL: nil)
                   // self.webView?.loadHTMLString(content, baseURL: nil)
                }
            }
            else {
                self.webView?.loadHTMLString("<font color= \(self.traitCollection.userInterfaceStyle == .dark ? "\'white\'" : "\'black\'")\">" + content + "</div>", baseURL: nil)
            }
        }
    }
    
    private func isHtml(_ value: String) -> Bool {
        if value.isEmpty {
            return false
        }
        return (value.range(of: "<(\"[^\"]*\"|'[^']*'|[^'\">])*>", options: .regularExpression) != nil)
    }
}

// MARK: - WKUIDelegate
extension InboxViewerWebMailBodyCell: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
        calculateWebviewHeight(webView: webView)
    }
    
    private func calculateWebviewHeight(webView: WKWebView) {
        let js = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='300%'"
        webView.evaluateJavaScript(js, completionHandler: { [weak self] (_, _) in
            webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
                if let height = height as? CGFloat {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.webView?.invalidateIntrinsicContentSize()
                        self?.thresholdHeight = self?.webView?.scrollView.contentSize.height ?? height - 200.0
                        self?.addConstraints()
                        if self?.isLoaded == false {
                            self?.isFromAfterTopCall = true
                            self?.isLoaded = true
                            self?.onHeightChange?()
                        }
                    }
                }
            })
        })
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
               let host = url.host, !host.hasPrefix("www.google.com"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
            
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DPrint("web view loading failed: \(error.localizedDescription)")
    }
}
/*
 private func heightOFcontent() {
 webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
 if complete != nil {
 var htmloffsetheight: CGFloat = 0
 var htmlscrollheight: CGFloat = 0
 self.webView.evaluateJavaScript("document.documentElement.offsetHeight", completionHandler: { (offsetHeight, error) in
 htmloffsetheight = offsetHeight as! CGFloat
 
 self.webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (scrollHeight, error) in
 htmlscrollheight = scrollHeight as! CGFloat
 
 if( htmloffsetheight == htmlscrollheight) {
 var newHeight  = htmloffsetheight
 if UIDevice.current.userInterfaceIdiom == .pad {
 newHeight = htmloffsetheight + 10
 }
 DispatchQueue.main.async {
 self.webViewHeightConstraint.constant = newHeight
 self.webView.scrollView.contentSize = CGSize(width: self.webView.frame.size.width, height: newHeight)
 if (self.isLoaded == false) {
 self.isLoaded = true
 self.onHeightChange?()
 }
 }
 }
 else {
 var newHeight  = htmloffsetheight / 2.70
 if UIDevice.current.userInterfaceIdiom == .pad {
 newHeight = htmloffsetheight + 10
 }
 DispatchQueue.main.async {
 self.webViewHeightConstraint.constant = newHeight
 self.webView.scrollView.contentSize = CGSize(width: self.webView.frame.size.width, height: newHeight)
 if (self.isLoaded == false) {
 self.isLoaded = true
 self.onHeightChange?()
 }
 }
 }
 
 })
 })
 }
 
 })
 }
 */
