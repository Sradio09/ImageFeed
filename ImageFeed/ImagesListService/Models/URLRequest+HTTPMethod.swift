import Foundation

extension URLRequest {
    var method: HTTPMethod? {
        get { HTTPMethod(rawValue: httpMethod ?? "") }
        set { httpMethod = newValue?.rawValue }
    }
}
