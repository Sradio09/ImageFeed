import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    @IBOutlet private var tableView: UITableView!
    
    private var presenter: ImagesListPresenterProtocol!
    private var lastReloadTime = Date(timeIntervalSince1970: 0)
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    // MARK: - Конфигурация MVP
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        presenter.viewDidLoad()
    }

    // MARK: - Updates
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard newCount > oldCount else {
            tableView.reloadData()
            return
        }
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        tableView.performBatchUpdates({
            tableView.insertRows(at: indexPaths, with: .automatic)
        })
    }
    
    // MARK: - Ошибка лайка
    func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось поставить лайк. Попробуйте ещё раз.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Row reload optimization
    private func reloadRowIfNeeded(at indexPath: IndexPath) {
        let now = Date()
        guard now.timeIntervalSince(lastReloadTime) > 0.3 else { return }
        lastReloadTime = now
        
        if let visibleIndexPaths = tableView.indexPathsForVisibleRows,
           visibleIndexPaths.contains(indexPath) {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let vc = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else { return }
            let photo = presenter.photo(at: indexPath)
            vc.fullImageURL = URL(string: photo.fullImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.photosCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else { return UITableViewCell() }
        
        let photo = presenter.photo(at: indexPath)
        imageCell.delegate = self

        if let url = URL(string: photo.thumbImageURL) {
            imageCell.photoImageView.kf.indicatorType = .activity
            imageCell.photoImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "Stub")
            ) { [weak self] result in
                guard let self else { return }
                if case .success = result {
                    self.reloadRowIfNeeded(at: indexPath)
                }
            }
        } else {
            imageCell.photoImageView.image = UIImage(named: "Stub")
        }

        imageCell.setIsLiked(photo.isLiked)
        imageCell.dateLabel.text = photo.createdAt.map {
            ImagesListCell.dateFormatter.string(from: $0)
        } ?? ""
        
        return imageCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        presenter.willDisplayCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photo(at: indexPath)
        let imageWidth = tableView.bounds.width
        return imageWidth / photo.aspectRatio
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = presenter.photo(at: indexPath)
        cell.setLikeLoading(true)
        presenter.changeLike(for: indexPath) { [weak self] success in
            guard let self else { return }
            DispatchQueue.main.async {
                cell.setLikeLoading(false)
                if success {
                    cell.setIsLiked(!photo.isLiked)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        }
    }
}

