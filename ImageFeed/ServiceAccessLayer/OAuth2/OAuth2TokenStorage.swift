import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}

    private let userDefaults = UserDefaults.standard
    private let tokenKey = "bearerToken"

    var token: String? {
        get {
            let token = userDefaults.string(forKey: tokenKey)
            print("📤 OAuth2TokenStorage - получен токен: \(token ?? "nil")")
            return token
        }
        set {
            print("💾 OAuth2TokenStorage - сохранение токена: \(newValue ?? "nil")")
            userDefaults.set(newValue, forKey: tokenKey)
        }
    }
}

