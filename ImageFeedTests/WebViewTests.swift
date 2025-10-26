@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "WebViewViewController"
        ) as! WebViewViewController
        
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsLoadRequest() {
        // given
        let viewController = WebViewViewControllerSpy()
        let helper = AuthHelper() // можно использовать стандартную конфигурацию
        let presenter = WebViewPresenter(view: viewController, authHelper: helper)
        viewController.presenter = presenter

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertTrue(viewController.loadRequestCalled, "Метод load(request:) должен быть вызван у вьюконтроллера")
    }
    
    func testProgressVisibleWhenLessThenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(view: nil, authHelper: authHelper)
        let progress: Float = 0.6

        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        // then
        XCTAssertFalse(shouldHideProgress, "Прогресс не должен скрываться, если значение меньше 1.0")
    }
    
    func testProgressHiddenWhenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(view: nil, authHelper: authHelper)
        let progress: Float = 1.0

        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        // then
        XCTAssertTrue(shouldHideProgress, "Прогресс должен скрываться, если значение равно 1.0")
    }


}

