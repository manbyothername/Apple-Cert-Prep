import Foundation
import UIKit
import FirebaseStorage

final class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage()
    private init() {}

    func uploadProfilePhoto(_ image: UIImage, userId: String, index: Int) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImage
        }
        let ref = storage.reference().child("profilePhotos/\(userId)/\(index).jpg")
        _ = try await ref.putDataAsync(imageData)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    enum StorageError: Error {
        case invalidImage
    }
}
