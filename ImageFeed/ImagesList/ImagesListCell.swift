import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer?
    var onLikeButtonTapped: (() -> Void)?
    
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
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        onLikeButtonTapped?()
    }
}
