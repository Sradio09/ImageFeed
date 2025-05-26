import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
            return formatter
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configCell(for cell: ImagesListCell, at indexPath: IndexPath) {
        
        let imageName = photosName[indexPath.row]
        cell.photoImageView.image = UIImage(named: imageName)
        
        let currentDate = Date()
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        
        cell.likeButton.isSelected = indexPath.row % 2 == 0
        
        cell.onLikeButtonTapped = {
            print("Лайк нажали в ячейке №\(indexPath.row)")
        }
    }
}


extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageName = photosName[indexPath.row]
        guard let image = UIImage(named: imageName) else {
                    return 200
                }
                
                let imageSize = image.size
                let imageViewWidth = tableView.bounds.width
                let scale = imageViewWidth / imageSize.width
                let imageViewHeight = imageSize.height * scale
                
                let topBottomInset: CGFloat = 24
                return imageViewHeight + topBottomInset
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
