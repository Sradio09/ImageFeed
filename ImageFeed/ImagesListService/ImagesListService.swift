import Foundation
import Logging
import CoreGraphics

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private let logger = Logger(label: "com.imagefeed.ImagesListService")
    
    private(set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    
    private lazy var isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    // MARK: - Очистка
    func clean() {
        photos.removeAll()
        lastLoadedPage = nil
        logger.info("🧹 Cleared photos cache")
    }
    
    // MARK: - Загрузка
    func fetchPhotosNextPage() {
        guard task == nil else {
            logger.debug("⚠️ fetchPhotosNextPage() called while task in progress — skipping")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        logger.info("🔵 Requesting page \(nextPage)")
        
        guard let request = makeRequest(page: nextPage) else {
            logger.error("❌ Failed to create request for page \(nextPage)")
            return
        }
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            self.task = nil
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { self.convert(photoResult: $0) }
                let uniquePhotos = newPhotos.filter { newPhoto in
                    !self.photos.contains(where: { $0.id == newPhoto.id })
                }
                
                guard !uniquePhotos.isEmpty else {
                    self.logger.notice("⚠️ No unique photos on page \(nextPage), skipping update")
                    return
                }
                
                self.lastLoadedPage = nextPage
                self.photos.append(contentsOf: uniquePhotos)
                self.logger.info("✅ Loaded \(uniquePhotos.count) new photos (page \(nextPage))")
                
                NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
                
            case .failure(let error):
                self.logger.error("[fetchPhotosNextPage]: \(error.localizedDescription)")
            }
        }
        
        task?.resume()
    }
    
    // MARK: - Лайки
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let method: HTTPMethod = isLike ? .post : .delete
        logger.debug("❤️ Changing like for photo \(photoId), isLike: \(isLike)")
        
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            let error = NSError(domain: "Invalid URL", code: -1)
            logger.error("❌ Invalid like URL for id \(photoId)")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.method = method
        request.setValue("Bearer \(OAuth2TokenStorage.shared.token ?? "")",
                         forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self else { return }
            
            if let error = error {
                self.logger.error("❌ Network error while changing like: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                self.logger.warning("⚠️ Unexpected response code while liking photo \(photoId)")
                completion(.failure(NSError(domain: "Bad response", code: -2)))
                return
            }
            
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let photo = self.photos[index]
                let updatedPhoto = Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    fullImageURL: photo.fullImageURL,
                    isLiked: isLike
                )
                self.photos = self.photos.withReplaced(itemAt: index, newValue: updatedPhoto)
                NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
                self.logger.info("💾 Updated like state for photo \(photoId)")
            }
            
            completion(.success(()))
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
        request.method = .get
        return request
    }
    
    private func convert(photoResult: PhotoResult) -> Photo {
        let size = CGSize(width: photoResult.width, height: photoResult.height)
        var date: Date? = nil
        
        if let createdAt = photoResult.createdAt {
            date = isoFormatter.date(from: createdAt)
            
            if date == nil {
                let fallbackFormatter = ISO8601DateFormatter()
                fallbackFormatter.formatOptions = [.withInternetDateTime]
                date = fallbackFormatter.date(from: createdAt)
            }
        }
        
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

