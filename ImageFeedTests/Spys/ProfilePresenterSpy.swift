@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didTapLogoutCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogout() {
        didTapLogoutCalled = true
    }
}

