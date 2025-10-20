import Foundation
import CoreGraphics

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String
    let isLiked: Bool
    
    var aspectRatio: CGFloat {
        size.height == 0 ? 1 : size.width / size.height
    }
}
