import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViewControllers()
        configureTabBarAppearance()
    }
    
    // MARK: - Setup View Controllers
    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // MARK: - Images List
        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {
            assertionFailure("❌ Не удалось найти ImagesListViewController в Storyboard")
            return
        }
        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.configure(imagesListPresenter)
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        // MARK: - Profile
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.configure(profilePresenter)
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        // MARK: - Combine
        viewControllers = [imagesListViewController, profileViewController]
    }
    
    // MARK: - Appearance
    private func configureTabBarAppearance() {
        let ypBlack = UIColor(named: "YP Black") ?? .black
        tabBar.barTintColor = ypBlack
        tabBar.backgroundColor = ypBlack
        tabBar.isTranslucent = false
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .lightGray
        
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = ypBlack
            appearance.shadowColor = .clear
            appearance.stackedLayoutAppearance.normal.iconColor = .lightGray
            appearance.stackedLayoutAppearance.selected.iconColor = .white
            tabBar.standardAppearance = appearance
        }
    }
}

