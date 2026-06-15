import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String
    var displayName: String
    var age: Int
    var bio: String
    var photoURLs: [String]
    var isVerified: Bool
    var flaggedBlockCount: Int
    var createdAt: Timestamp

    var hasPhoto: Bool { !photoURLs.isEmpty }

    // Used to sort grid: verified+photo first, photo-only second, no-photo last
    var visibilityScore: Int {
        if isVerified && hasPhoto { return 2 }
        if hasPhoto { return 1 }
        return 0
    }
}
