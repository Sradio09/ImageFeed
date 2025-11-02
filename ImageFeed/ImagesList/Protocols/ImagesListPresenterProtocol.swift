import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func photo(at indexPath: IndexPath) -> Photo
    func willDisplayCell(at indexPath: IndexPath)
    func didSelectPhoto(at indexPath: IndexPath)
    func changeLike(for indexPath: IndexPath, completion: @escaping (Bool) -> Void)
}

