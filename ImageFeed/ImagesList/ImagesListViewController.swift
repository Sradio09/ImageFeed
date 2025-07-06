import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let defaultRowHeight: CGFloat = 200
    private let verticalPadding: CGFloat = 24
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegueIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        guard
            let viewController = segue.destination as? SingleImageViewController,
            let indexPath = sender as? IndexPath
        else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        let imageName = photosName[indexPath.row]
        viewController.image = UIImage(named: imageName)
    }
    
    
    
    private func configCell(for cell: ImagesListCell, at indexPath: IndexPath) {
        
        let imageName = photosName[indexPath.row]
        cell.photoImageView.image = UIImage(named: imageName)
        
        let currentDate = Date()
        cell.dateLabel.text = DateFormatter.longStyle.string(from: currentDate)
        
        cell.likeButton.isSelected = indexPath.row % 2 == 0
        
        cell.onLikeButtonTapped = {
            print("Лайк нажали в ячейке №\(indexPath.row)")
        }
    }
}

extension DateFormatter {
    static let longStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU") // Учитываем локализацию
        return formatter
    }()
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageName = photosName[indexPath.row]
        guard let image = UIImage(named: imageName) else {
            return defaultRowHeight
        }
        
        let scale = tableView.bounds.width / image.size.width
                return image.size.height * scale + verticalPadding
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, at: indexPath)
        return imageListCell
    }
    
}
