import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask {
        dataTask(with: request) { data, response, error in
            if let error {
                print("[objectTask]: NetworkError - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                let error = URLError(.badServerResponse)
                print("[objectTask]: InvalidResponseError - нет HTTPURLResponse")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard (200..<300).contains(response.statusCode) else {
                let errorString = data.flatMap { String(data: $0, encoding: .utf8) } ?? "No data"
                print("[objectTask]: HTTPError - код: \(response.statusCode), данные: \(errorString)")
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            
            guard let data = data else {
                let error = URLError(.zeroByteResource)
                print("[objectTask]: EmptyDataError - данные отсутствуют")
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
                print("[objectTask]: DecodingError - \(error.localizedDescription), данные: \(String(data: data, encoding: .utf8) ?? "")")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

