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
    private let tokenStorage = OAuth2TokenStorage.shared
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard lastCode != code else { return }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(OAuth2Error.invalidRequest))
            return
        }
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let responseBody):
                let token = responseBody.accessToken
                self?.tokenStorage.token = token
                completion(.success(token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyParams = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    enum OAuth2Error: Error {
        case invalidRequest
    }
}

