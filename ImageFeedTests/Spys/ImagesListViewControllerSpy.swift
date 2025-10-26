@testable import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var showLikeErrorAlertCalled = false
    var receivedOldCount: Int?
    var receivedNewCount: Int?

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
        receivedOldCount = oldCount
        receivedNewCount = newCount
    }

    func showLikeErrorAlert() {
        showLikeErrorAlertCalled = true
    }
}

