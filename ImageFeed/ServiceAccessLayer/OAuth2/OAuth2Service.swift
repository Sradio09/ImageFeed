import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private var task: URLSessionTask?
    private var lastCode: String?
    private var completions: [(Result<String, Error>) -> Void] = []
    private let tokenStorage = OAuth2TokenStorage.shared
    
    // MARK: - Local constants
    private enum OAuth2Constants {
        static let syncQueueLabel = "com.Mikhail.OAuth2Service.syncQueue"
        static let tokenURL = "https://unsplash.com/oauth/token"
    }
    
    private let syncQueue = DispatchQueue(label: OAuth2Constants.syncQueueLabel)
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        syncQueue.async {
            if self.lastCode == code, self.task != nil {
                self.completions.append(completion)
                return
            }
            
            if self.lastCode != code {
                self.task?.cancel()
                self.task = nil
                self.completions.removeAll()
            }
            
            self.lastCode = code
            self.completions.append(completion)
            
            guard let request = self.makeOAuthTokenRequest(code: code) else {
                self.completeAll(with: .failure(OAuth2Error.invalidRequest))
                return
            }
            
            let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
                guard let self = self else { return }
                
                self.syncQueue.async {
                    switch result {
                    case .success(let responseBody):
                        let token = responseBody.accessToken
                        self.tokenStorage.token = token
                        self.completeAll(with: .success(token))
                    case .failure(let error):
                        print("[OAuth2Service.fetchOAuthToken]: Failure - \(error.localizedDescription), code: \(code)")
                        self.completeAll(with: .failure(error))
                    }
                    self.task = nil
                }
            }
            
            self.task = task
            task.resume()
        }
    }
    
    private func completeAll(with result: Result<String, Error>) {
        let completionsCopy = self.completions
        self.completions.removeAll()
        self.lastCode = nil
        DispatchQueue.main.async {
            completionsCopy.forEach { $0(result) }
        }
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: OAuth2Constants.tokenURL) else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .post
        let bodyParams = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        urlRequest.httpBody = bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return urlRequest
    }
    
    enum OAuth2Error: Error {
        case invalidRequest
    }
}

