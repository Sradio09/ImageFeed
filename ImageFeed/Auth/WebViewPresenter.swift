import Foundation
import WebKit

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    private let authHelper: AuthHelperProtocol

    init(view: WebViewViewControllerProtocol?, authHelper: AuthHelperProtocol = AuthHelper()) {
        self.view = view
        self.authHelper = authHelper
    }

    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        view?.setProgressValue(Float(newValue))
        view?.setProgressHidden(shouldHideProgress(for: Float(newValue)))
    }

    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }

    func code(from navigationAction: WKNavigationAction) -> String? {
        guard let url = navigationAction.request.url else { return nil }
        return authHelper.code(from: url)
    }
}

