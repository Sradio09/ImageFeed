import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    
    func fetchProfileImageURL(
        username: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(
                domain: "ProfileImageService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"]
            )))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let userResult):
                let avatar = userResult.profileImage.small
                self.avatarURL = avatar
                completion(.success(avatar))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatar]
                )
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: Failure - \(error.localizedDescription), username: \(username)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

