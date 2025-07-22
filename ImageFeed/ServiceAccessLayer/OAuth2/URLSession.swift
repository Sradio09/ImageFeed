import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask {
        dataTask(with: request) { data, response, error in
            if let error {
                print("Network error:", error)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                let error = URLError(.badServerResponse)
                print("Invalid response")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard (200..<300).contains(response.statusCode) else {
                let errorString = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No data"
                print("HTTP error \(response.statusCode):", errorString)
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            
            guard let data = data else {
                let error = URLError(.zeroByteResource)
                print("No data received")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch {
                print("Decoding error:", error)
                print("Raw response:", String(data: data, encoding: .utf8) ?? "nil")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
