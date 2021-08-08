import UIKit
import WebKit
import Utility

class FAQViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!

    // MARK: Properties
    var dataSource: FAQDataSource?
    var presenter: FAQPresenter?
    var router: FAQRouter?
    private var webView: WKWebView?
    
    let progressView = UIProgressView(progressViewStyle: .default)
    private var estimatedProgressObserver: NSKeyValueObservation?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
                
        let configurator = FAQConfigurator()
        configurator.configure(viewController: self)
        navigationItem.title = dataSource?.navigationTitle

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
        setupProgressView()
        setupEstimatedProgressObserver()
        
        guard let urlString = dataSource?.FAQURLString,
            let url = URL(string: urlString) else {
            return
        }
        
    
        setupWebview(url: url)
        
        
//        Loader.start()
//        let urlRequest = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 15.0)
//        webView?.load(urlRequest)
//        webView?.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
//
//        //webView?.load(URLRequest(url: url))
    }
    
    // MARK: - Private methods
    private func setupProgressView() {
        guard let navigationBar = navigationController?.navigationBar else { return }

        progressView.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(progressView)

        progressView.isHidden = true

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),

            progressView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2.0)
        ])
    }

    private func setupEstimatedProgressObserver() {
        estimatedProgressObserver = webView?.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            self?.progressView.progress = Float(webView.estimatedProgress)
        }
    }

    private func setupWebview(url: URL) {
        let request = URLRequest(url: url)

        webView?.navigationDelegate = self
        webView!.load(request)
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
        //Loader.stop()
        UIView.animate(withDuration: 0.33,
                            animations: {
                                self.progressView.alpha = 0.0
                            },
                            completion: { isFinished in
                                // Update `isHidden` flag accordingly:
                                //  - set to `true` in case animation was completly finished.
                                //  - set to `false` in case animation was interrupted, e.g. due to starting of another animation.
                                self.progressView.isHidden = isFinished
             })
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //Loader.stop()
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if progressView.isHidden {
                   // Make sure our animation is visible.
                   progressView.isHidden = false
               }

               UIView.animate(withDuration: 0.33,
                              animations: {
                                  self.progressView.alpha = 1.0
               })
    }
}
