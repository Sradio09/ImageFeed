import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?

    var photosCount: Int { photos.count }

    // MARK: - Lifecycle
    func viewDidLoad() {
        photos = imagesListService.photos
        observeChanges()
        imagesListService.fetchPhotosNextPage()
    }

    private func observeChanges() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let oldCount = self.photos.count
            let newCount = self.imagesListService.photos.count
            self.photos = self.imagesListService.photos
            self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }

    func photo(at indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }

    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }

    func didSelectPhoto(at indexPath: IndexPath) {
        // переход в контроллер — остаётся на стороне VC
    }

    func changeLike(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let photo = photos[indexPath.row]
        let newState = !photo.isLiked
        imagesListService.changeLike(photoId: photo.id, isLike: newState) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    completion(true)
                case .failure:
                    self.view?.showLikeErrorAlert()
                    completion(false)
                }
            }
        }
    }

    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

