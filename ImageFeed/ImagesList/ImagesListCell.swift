import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer?
    private var isLoadingLike = false
    private var activityIndicator: UIActivityIndicatorView?
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addGradient()
        
        gradientView.layer.cornerRadius = 16
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientView.layer.masksToBounds = true
    }
    
    private func addGradient() {
        gradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        
        gradientView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    // MARK: - Конфигурация
    func configure(with photo: Photo) {
        if let url = URL(string: photo.thumbImageURL) {
            photoImageView.kf.indicatorType = .activity
            photoImageView.kf.setImage(with: url)
        } else {
            photoImageView.image = UIImage(resource: .stub)
        }
        
        if let date = photo.createdAt {
            dateLabel.text = Self.dateFormatter.string(from: date)
        } else {
            dateLabel.text = ""
        }
        
        setIsLiked(photo.isLiked)
    }
    // MARK: - Лайк
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        guard !isLoadingLike else { return }
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "likeButtonOn" : "likeButtonOff"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
        likeButton.isSelected = isLiked
    }
    
    func setLikeLoading(_ isLoading: Bool) {
        isLoadingLike = isLoading
        likeButton.isEnabled = !isLoading
        
        if isLoading {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.color = .white
            indicator.center = CGPoint(x: likeButton.bounds.midX, y: likeButton.bounds.midY)
            indicator.startAnimating()
            likeButton.addSubview(indicator)
            activityIndicator = indicator
            likeButton.setImage(nil, for: .normal)
        } else {
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
            let imageName = likeButton.isSelected ? "likeButtonOn" : "likeButtonOff"
            likeButton.setImage(UIImage(named: imageName), for: .normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.kf.cancelDownloadTask()
        photoImageView.image = nil
        likeButton.isSelected = false
        dateLabel.text = nil
        isLoadingLike = false
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }
}

