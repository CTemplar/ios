//
//  PrivacyAndTermsViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 26.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class PrivacyAndTermsViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
   
    var mode: TextControllerMode!
    
    @IBOutlet var webView               : WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        self.setupScreen()
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupScreen() {
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: k_contactsBarTintColor]
        
        var urlString : String = ""
        
        switch mode.rawValue {
        case TextControllerMode.privacyPolicy.rawValue:
            self.navigationItem.title = "privacyPolicy".localized()
            urlString = k_privacyURL
            break
        case TextControllerMode.termsAndConditions.rawValue:
            self.navigationItem.title = "termsAndConditions".localized()
            urlString = k_termsURL
            break
        default:
            break
        }
        
        self.loadText(urlString: urlString)
    }
    
    func loadText(urlString: String) {
        
        let url = URL(string: urlString)!
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Loader.stop()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Loader.start()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Loader.stop()
    }
}
