@testable import ImageFeed
import XCTest

final class ProfileViewControllerTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let sut = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        sut.configure(presenterSpy)

        // when
        _ = sut.view

        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func testDidTapLogoutButtonCallsPresenter() {
        // given
        let sut = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        sut.configure(presenterSpy)

        // when
        sut.performSelector(onMainThread: #selector(ProfileViewController.didTapLogoutButton),
                            with: nil, waitUntilDone: true)

        // then
        XCTAssertTrue(presenterSpy.didTapLogoutCalled)
    }
}

