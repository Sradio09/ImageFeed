import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

final class ProfileService {
    static let shared = ProfileService()
    
    private init() {}
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    private var lastToken: String?
    private var completions: [(Result<Profile, Error>) -> Void] = []
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        if lastToken == token, task != nil {
            completions.append(completion)
            return
        }
        
        if lastToken != token {
            task?.cancel()
            task = nil
            completions.removeAll()
        }
        
        lastToken = token
        completions.append(completion)
        
        guard let request = makeProfileRequest(token: token) else {
            completeAll(with: .failure(ProfileError.invalidRequest))
            return
        }
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: [profileResult.firstName, profileResult.lastName].compactMap { $0 }.joined(separator: " "),
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio
                )
                self.profile = profile
                self.completeAll(with: .success(profile))
            case .failure(let error):
                print("[ProfileService.fetchProfile]: Failure - \(error.localizedDescription), token: \(token)")
                self.completeAll(with: .failure(error))
            }
            self.task = nil
        }
        task?.resume()
        
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func completeAll(with result: Result<Profile, Error>) {
        completions.forEach { $0(result) }
        completions.removeAll()
    }
    
    enum ProfileError: Error {
        case invalidRequest
    }
}

 
