import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer?

    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        addGradient()
        
        gradientView.layer.cornerRadius = 16
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.kf.cancelDownloadTask()
        photoImageView.image = nil
        dateLabel.text = nil
        likeButton.setImage(UIImage(named: "like_off"), for: .normal)
        gradientLayer?.removeFromSuperlayer()
    }

    // MARK: - Configuration
    func configure(with photo: Photo) {
        // Изображение
        if let url = URL(string: photo.thumbImageURL) {
            photoImageView.kf.indicatorType = .activity
            photoImageView.kf.setImage(with: url, placeholder: UIImage(named: "Stub"))
        } else {
            photoImageView.image = UIImage(named: "Stub")
        }

        // Дата
        if let date = photo.createdAt {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "d MMMM yyyy"
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = ""
        }

        // Лайк
        let likeImage = photo.isLiked ? UIImage(named: "likeButtonOn") : UIImage(named: "likeButtonOff")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked ? UIImage(named: "likeButtonOn") : UIImage(named: "likeButtonOff")
        likeButton.setImage(image, for: .normal)
    }

    // MARK: - Actions
    @IBAction private func likeButtonTapped(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }

    // MARK: - Gradient
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
}

