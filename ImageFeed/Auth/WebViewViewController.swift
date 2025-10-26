import UIKit
import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?

    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    weak var delegate: WebViewViewControllerDelegate?
    private var progressObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        setupProgressObserver()
        presenter?.viewDidLoad()
        
        webView.accessibilityIdentifier = "UnsplashWebView"

    }
    
    // MARK: - WebViewViewControllerProtocol methods
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    // MARK: - Private
    private func setupProgressObserver() {
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            guard let self = self, let progress = change.newValue else { return }
            self.presenter?.didUpdateProgressValue(progress)
        }
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = presenter?.code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

