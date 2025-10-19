
import UIKit
import Kingfisher

private enum ProfileUIConstants {
    static let imageSize: CGFloat = 70
    static let buttonSize: CGFloat = 44
    static let horizontalPadding: CGFloat = 16
    static let topPadding: CGFloat = 32
    static let spacing: CGFloat = 8
}

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    private let imageView = UIImageView(image: UIImage(named: "avatar"))
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton(type: .custom)
    
    // MARK: - Properties
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUI()
        setupLayout()
        setupObservers()
        updateAvatar()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .ypBlack
    }
    
    private func setupUI() {
        // Настройка аватарки
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Имя
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .ypWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Логин
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.textColor = .ypGray
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Описание
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Кнопка выхода
        logoutButton.setImage(UIImage(named: "Exit"), for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавление всех сабвью
        [imageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
        }
    }
    
    // MARK: - Layout
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
    
    // MARK: - Observers
    private func setupObservers() {
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    // MARK: - Update UI
    private func updateProfileDetails(_ profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        print("imageUrl: \(url)")
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70,
                                                           weight: .regular,
                                                           scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]
        ) { result in
            switch result {
            case .success(let value):
                print("✅ Avatar loaded from: \(value.source)")
            case .failure(let error):
                print("❌ Avatar load error: \(error)")
            }
        }
    }
    
    // MARK: - Actions
    @objc
    private func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Выход из аккаунта",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()

            guard let window = UIApplication.shared.windows.first else { return }
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
            window.makeKeyAndVisible()
        })

        present(alert, animated: true)
    }
    
    // MARK: - Deinit
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

