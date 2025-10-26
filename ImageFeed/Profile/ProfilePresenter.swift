import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?

    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(
                name: profile.name,
                login: profile.loginName,
                bio: profile.bio ?? ""
            )
        }
        if let avatarString = profileImageService.avatarURL,
           let url = URL(string: avatarString) {
            view?.updateAvatar(with: url)
        }
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self,
                  let avatarString = self.profileImageService.avatarURL,
                  let url = URL(string: avatarString)
            else { return }

            self.view?.updateAvatar(with: url)
        }
    }

    func didTapLogout() {
        view?.showLogoutAlert()
    }

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

