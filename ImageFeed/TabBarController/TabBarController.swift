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
        
        // Первый экран — лента
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        // Второй экран — профиль
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        // Устанавливаем контроллеры таббара
        self.viewControllers = [imagesListViewController, profileViewController]
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

