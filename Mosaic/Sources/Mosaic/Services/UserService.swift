import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    private init() {}

    func createUser(_ user: AppUser) throws {
        try db.collection("users").document(user.uid).setData(from: user)
    }

    func fetchUser(uid: String) async throws -> AppUser {
        let doc = try await db.collection("users").document(uid).getDocument()
        return try doc.data(as: AppUser.self)
    }

    func updateUser(_ user: AppUser) throws {
        guard let id = user.id else { return }
        try db.collection("users").document(id).setData(from: user, merge: true)
    }

    func fetchDiscoveryUsers(excludingIds: [String]) async throws -> [AppUser] {
        let snapshot = try await db.collection("users").limit(to: 200).getDocuments()
        return try snapshot.documents
            .compactMap { try? $0.data(as: AppUser.self) }
            .filter { !excludingIds.contains($0.uid) }
            .sorted { $0.visibilityScore > $1.visibilityScore }
    }

    func incrementFlaggedBlockCount(for uid: String) async throws {
        try await db.collection("users").document(uid)
            .updateData(["flaggedBlockCount": FieldValue.increment(Int64(1))])
    }
}
