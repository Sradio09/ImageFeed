import UIKit
import Kingfisher

private enum ProfileUIConstants {
    static let imageSize: CGFloat = 70
    static let buttonSize: CGFloat = 44
    static let horizontalPadding: CGFloat = 16
    static let topPadding: CGFloat = 32
    static let spacing: CGFloat = 8
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    // MARK: - Presenter
    private var presenter: ProfilePresenterProtocol!
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    // MARK: - UI Elements
    private let imageView = UIImageView(image: UIImage(named: "avatar"))
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton(type: .custom)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUI()
        setupLayout()
        presenter.viewDidLoad()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .ypBlack
    }
    
    private func setupUI() {
        [imageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .ypWhite
        nameLabel.accessibilityIdentifier = "nameLabel"
        
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.textColor = .ypGray
        loginNameLabel.accessibilityIdentifier = "loginLabel"
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.accessibilityIdentifier = "descriptionLabel"
        
        logoutButton.setImage(UIImage(named: "Exit"), for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        logoutButton.accessibilityIdentifier = "logoutВutton"
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                               constant: ProfileUIConstants.horizontalPadding),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: ProfileUIConstants.topPadding),
            imageView.widthAnchor.constraint(equalToConstant: ProfileUIConstants.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: ProfileUIConstants.imageSize),
            
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,
                                           constant: ProfileUIConstants.spacing),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,
                                                constant: ProfileUIConstants.spacing),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor,
                                                  constant: ProfileUIConstants.spacing),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -ProfileUIConstants.horizontalPadding),
            logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: ProfileUIConstants.buttonSize),
            logoutButton.heightAnchor.constraint(equalToConstant: ProfileUIConstants.buttonSize)
        ])
    }
    
    // MARK: - UI Updates (ProfileViewControllerProtocol)
    func updateProfileDetails(name: String, login: String, bio: String) {
        nameLabel.text = name
        loginNameLabel.text = login
        descriptionLabel.text = bio
    }
    
    func updateAvatar(with url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "avatar"),
                              options: [.processor(processor)])
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Выход из аккаунта",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()
            guard let window = UIApplication.shared.windows.first else { return }
            let splashVC = SplashViewController()
            window.rootViewController = splashVC
            window.makeKeyAndVisible()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc func didTapLogoutButton() {
        presenter.didTapLogout()
    }
}

