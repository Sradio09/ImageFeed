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
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
    // MARK: - Appearance
    private func configureTabBarAppearance() {
        // Загружаем цвет из ассетов
        let ypBlack = UIColor(named: "YP Black") ?? .black

        // Базовые цвета таббара
        tabBar.barTintColor = ypBlack
        tabBar.backgroundColor = ypBlack
        tabBar.isTranslucent = false
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .lightGray

        // Для iOS 13+ — задаём стабильный внешний вид
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

