import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class BlockService {
    static let shared = BlockService()
    private let db = Firestore.firestore()
    private init() {}

    func block(blockerId: String, blockedId: String, reason: BlockReason?) async throws {
        let block = Block.make(blockerId: blockerId, blockedId: blockedId, reason: reason)
        try db.collection("blocks").addDocument(from: block)
        if block.flagged {
            try await UserService.shared.incrementFlaggedBlockCount(for: blockedId)
        }
    }

    func fetchBlockedIds(for userId: String) async throws -> Set<String> {
        let snapshot = try await db.collection("blocks")
            .whereField("blockerId", isEqualTo: userId)
            .getDocuments()
        let blocks = snapshot.documents.compactMap { try? $0.data(as: Block.self) }
        return Set(blocks.map { $0.blockedId })
    }
}
