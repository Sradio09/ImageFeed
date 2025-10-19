import Foundation
import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}

    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    
    func clean() {
            photos.removeAll()
        }
    
    func fetchPhotosNextPage() {
        if task != nil { return }

        let nextPage = (lastLoadedPage ?? 0) + 1
        print("🔵 Requesting page:", nextPage)

        guard let request = makeRequest(page: nextPage) else { return }

        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResults):
                    let newPhotos = photoResults.map { self.convert(photoResult: $0) }
                    
                    let uniquePhotos = newPhotos.filter { newPhoto in
                        !self.photos.contains(where: { $0.id == newPhoto.id })
                    }
                    
                    if !uniquePhotos.isEmpty {
                        self.lastLoadedPage = nextPage
                        self.photos.append(contentsOf: uniquePhotos)
                        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    } else {
                        print("⚠️ No unique photos on page \(nextPage), skipping update")
                    }
                    
                case .failure(let error):
                    print("[ImagesListService.fetchPhotosNextPage]: [\(type(of: error))] \(error.localizedDescription)")
                }

                self.task = nil
            }
        }

        task?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let httpMethod = isLike ? "POST" : "DELETE"

        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(OAuth2TokenStorage.shared.token ?? "")", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    completion(.failure(NSError(domain: "Bad response", code: -2)))
                    return
                }
                
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        fullImageURL: photo.fullImageURL,
                        isLiked: isLike
                    )
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }

                completion(.success(()))
            }
        }
        task.resume()
    }

    // MARK: - Helpers

    private func makeRequest(page: Int) -> URLRequest? {
        guard var components = URLComponents(string: "https://api.unsplash.com/photos") else { return nil }
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "client_id", value: Constants.accessKey)
        ]
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }

    private func convert(photoResult: PhotoResult) -> Photo {
        let size = CGSize(width: photoResult.width, height: photoResult.height)
        let date = ISO8601DateFormatter().date(from: photoResult.createdAt ?? "")
        
        return Photo(
                id: photoResult.id,
                size: size,
                createdAt: date,
                welcomeDescription: photoResult.description,
                thumbImageURL: photoResult.urls.thumb,
                largeImageURL: photoResult.urls.regular,
                fullImageURL: photoResult.urls.full,
                isLiked: photoResult.likedByUser
        )
    }
}

// MARK: - Array Helper

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}

