import Foundation
import UIKit
import Utility
import WebKit

public final class InboxViewerWebMailBodyCell: UITableViewCell, Cellable {
    
    // MARK: Properties
    public typealias ModelType = TextMail
    
    var onHeightChange: (() -> Void)?
    
    private let mailBodyWebView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsAirPlayForMediaPlayback = true
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.allowsPictureInPictureMediaPlayback = true
        webConfiguration.dataDetectorTypes = .all
        
        let preferences = WKPreferences()
        preferences.isFraudulentWebsiteWarningEnabled = true
        preferences.javaScriptEnabled = true
        webConfiguration.preferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.allowsLinkPreview = true
        webView.isOpaque = false
        return webView
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.tintColor = AppStyle.Colors.loaderColor.color
        activity.hidesWhenStopped = true
        return activity
    }()
    
    // MARK: - Constructor
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
    }
    
    // MARK: - Setup UI
    private func buildLayout() {
        backgroundColor = .systemBackground
        
        addSubview(mailBodyWebView)
        
        addSubview(activityIndicatorView)
        
        activityIndicatorView.isHidden = true
        
        mailBodyWebView.snp.makeConstraints { (maker) in
            maker.left.equalTo(8.0)
            maker.right.equalTo(-8.0)
            maker.top.bottom.equalToSuperview()
            maker.height.equalTo(100.0)
        }
        
        activityIndicatorView.snp.makeConstraints { (maker) in
            maker.center.centerX.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    public func configure(with model: TextMail) {
        activityIndicatorView.startAnimating()
        mailBodyWebView.navigationDelegate = self
        
        let colorCode = traitCollection.userInterfaceStyle == .light ? "color:#000000;" : "color:#ffffff;"
        
        let mailString = model.content.replacingOccurrences(of: "color: rgb(0, 0, 0);", with: colorCode)
        
        mailBodyWebView.loadHTMLString("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />" + "<div style=\"color:\(traitCollection.userInterfaceStyle == .dark ? "#ffffff" : "#000000")\">" + mailString.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "") + "</div>", baseURL: nil)
    }
}
// MARK: - WKUIDelegate
extension InboxViewerWebMailBodyCell: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        mailBodyWebView.evaluateJavaScript("document.readyState", completionHandler: { [weak self] (complete, error) in
            if complete != nil {
                self?.mailBodyWebView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    if let height = height as? CGFloat {
                        self?.mailBodyWebView.snp.updateConstraints({ (make) in
                            make.height.equalTo(height)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                UIView.animate(withDuration: 0.3) {
                                    self?.onHeightChange?()
                                    self?.activityIndicatorView.stopAnimating()
                                }
                            }
                        })
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
