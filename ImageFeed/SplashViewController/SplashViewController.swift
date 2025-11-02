import UIKit


final class SplashViewController: UIViewController {
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "splash_screen_logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private var isAuthorizing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack  
        setupLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if let token = storage.token {
            print("🔑 SplashViewController token:", token)
            fetchProfile(token)
        } else if !isAuthorizing {
            isAuthorizing = true
            showAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - UI Setup
    private func setupLogo() {
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Navigation
    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("❌ Не удалось создать AuthViewController из Storyboard")
            return
        }
        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }
    
    // MARK: - Network
    private func fetchProfile(_ token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let profile):
                print("✅ Profile loaded:", profile)
                
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                }
            case .failure(let error):
                print("❌ Ошибка загрузки профиля:", error)
            }
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        if let tabBarController = tabBarController as? UITabBarController,
           let viewControllers = tabBarController.viewControllers {
            for viewController in viewControllers {
                if let navController = viewController as? UINavigationController,
                   let profileVC = navController.topViewController as? ProfileViewController {
                    let presenter = ProfilePresenter()
                    profileVC.configure(presenter)
                }
            }
        }

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self, let token = self.storage.token else {
                assertionFailure("No token after auth")
                return
            }
            self.fetchProfile(token)
        }
    }
}

