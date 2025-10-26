@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {

    func testViewDidLoadCallsPresenterViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController

        let presenterSpy = ImagesListPresenterSpy()
        sut.configure(presenterSpy)

        // when
        _ = sut.view // вызывает viewDidLoad()

        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled,
                      "Метод viewDidLoad() презентера должен вызываться при загрузке view.")
    }

    func testPresenterCallsUpdateTableViewOnChange() {
        // given
        let viewSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        presenter.view = viewSpy

        // when
        viewSpy.updateTableViewAnimated(oldCount: 0, newCount: 5)

        // then
        XCTAssertTrue(viewSpy.updateTableViewAnimatedCalled,
                      "Метод updateTableViewAnimated(oldCount:newCount:) должен вызываться у вью при изменении данных.")
        XCTAssertEqual(viewSpy.receivedOldCount, 0)
        XCTAssertEqual(viewSpy.receivedNewCount, 5)
    }

    func testChangeLikeCallsPresenterAndCompletion() {
        // given
        let presenterSpy = ImagesListPresenterSpy()
        var completionCalled = false

        // when
        presenterSpy.changeLike(for: IndexPath(row: 0, section: 0)) { success in
            completionCalled = success
        }

        // then
        XCTAssertTrue(presenterSpy.didTapLikeCalled,
                      "Метод changeLike(for:completion:) должен быть вызван у презентера.")
        XCTAssertEqual(presenterSpy.tappedIndexPath, IndexPath(row: 0, section: 0))
        XCTAssertTrue(completionCalled,
                      "Completion должен быть вызван с true.")
    }
}

