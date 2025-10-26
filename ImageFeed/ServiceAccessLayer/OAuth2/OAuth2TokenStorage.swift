import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "bearerToken"
    
    var token: String? {
        get {
            let token = KeychainWrapper.standard.string(forKey: tokenKey)
            print("📤 OAuth2TokenStorage - получен токен из Keychain: \(token ?? "nil")")
            return token
        }
        set {
            if let token = newValue {
                let isSuccess = KeychainWrapper.standard.set(token, forKey: tokenKey)
                print("💾 OAuth2TokenStorage - сохранение токена в Keychain: \(token), успех: \(isSuccess)")
            } else {
                let isSuccess = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                print("🗑 OAuth2TokenStorage - удаление токена из Keychain, успех: \(isSuccess)")
            }
        }    }
}

