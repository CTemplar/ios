import UIKit
import WebKit

class FAQViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!

    // MARK: Properties
    var dataSource: FAQDataSource?
    var sideMenuViewController: InboxSideMenuViewController?
    var presenter:FAQPresenter?
    var router: FAQRouter?
    private var webView: WKWebView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "FAQ".localized()
        
        let configurator = FAQConfigurator()
        configurator.configure(viewController: self)
        
        setupWebView()
        openFAQLink()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (Device.IS_IPAD) {
            presenter?.setupNavigationLeftItem()
        }
    }
    
    // MARK: - Setup
    private func setupWebView() {
        webView = WKWebView(frame: self.view.frame)
        webView?.translatesAutoresizingMaskIntoConstraints = false
        webView?.isUserInteractionEnabled = true
        webView?.navigationDelegate = self
        view.addSubview(self.webView!)
        webView?.layout(.left, .right, .top, .bottom, to: view)
    }
    
    // MARK: - Actions
    private func openFAQLink() {
        guard let urlString = dataSource?.FAQURLString,
            let url = URL(string: urlString) else {
            return
        }
        Loader.start()
        webView?.load(URLRequest(url: url))
    }
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        self.router?.showInboxSideMenu()
    }
    
    // MARK: - Orientation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if (Device.IS_IPAD) {
            presenter?.setupNavigationLeftItem()
        }
    }
}

// MARK: - WKNavigationDelegate
extension FAQViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Loader.stop()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Loader.stop()
    }
}
