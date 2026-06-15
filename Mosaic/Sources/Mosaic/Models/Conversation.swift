import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Conversation: Identifiable, Codable {
    @DocumentID var id: String?
    var participantIds: [String]
    var lastMessage: String
    var lastMessageTimestamp: Timestamp
    var unreadCount: Int

    func otherParticipantId(currentUserId: String) -> String? {
        participantIds.first { $0 != currentUserId }
    }
}
