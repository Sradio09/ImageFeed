@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled = false
    var didTapLikeCalled = false
    var tappedIndexPath: IndexPath?
    
    var photosCount: Int = 10
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        return Photo(
            id: "test",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "description",
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            fullImageURL: "https://example.com/full.jpg",
            isLiked: false
        )
    }

    
    func willDisplayCell(at indexPath: IndexPath) {
    }
    
    func didSelectPhoto(at indexPath: IndexPath) {
    }
    
    func changeLike(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        didTapLikeCalled = true
        tappedIndexPath = indexPath
        completion(true)
    }
}

