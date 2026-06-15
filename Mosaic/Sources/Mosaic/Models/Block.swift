import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Block: Identifiable, Codable {
    @DocumentID var id: String?
    var blockerId: String
    var blockedId: String
    var reason: BlockReason?
    // true when no reason was provided — shown publicly on the blocker's profile
    var flagged: Bool
    var timestamp: Timestamp

    static func make(blockerId: String, blockedId: String, reason: BlockReason?) -> Block {
        Block(
            blockerId: blockerId,
            blockedId: blockedId,
            reason: reason,
            flagged: reason == nil,
            timestamp: Timestamp(date: Date())
        )
    }
}
