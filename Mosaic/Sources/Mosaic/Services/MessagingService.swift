import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class MessagingService {
    static let shared = MessagingService()
    private let db = Firestore.firestore()
    private init() {}

    func fetchOrCreateConversation(between userId1: String, and userId2: String) async throws -> Conversation {
        let participants = [userId1, userId2].sorted()
        let snapshot = try await db.collection("conversations")
            .whereField("participantIds", isEqualTo: participants)
            .limit(to: 1)
            .getDocuments()

        if let doc = snapshot.documents.first, let existing = try? doc.data(as: Conversation.self) {
            return existing
        }

        let new = Conversation(
            participantIds: participants,
            lastMessage: "",
            lastMessageTimestamp: Timestamp(date: Date()),
            unreadCount: 0
        )
        let ref = try db.collection("conversations").addDocument(from: new)
        var created = new
        created.id = ref.documentID
        return created
    }

    func sendMessage(conversationId: String, senderId: String, text: String) async throws {
        let message = Message(senderId: senderId, text: text, timestamp: Timestamp(date: Date()), isRead: false)
        try db.collection("conversations").document(conversationId)
            .collection("messages").addDocument(from: message)
        try await db.collection("conversations").document(conversationId).updateData([
            "lastMessage": text,
            "lastMessageTimestamp": Timestamp(date: Date())
        ])
    }

    func messagesListener(conversationId: String, onUpdate: @escaping ([Message]) -> Void) -> ListenerRegistration {
        db.collection("conversations").document(conversationId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, _ in
                let messages = (snapshot?.documents ?? []).compactMap { try? $0.data(as: Message.self) }
                onUpdate(messages)
            }
    }

    func conversationsListener(userId: String, onUpdate: @escaping ([Conversation]) -> Void) -> ListenerRegistration {
        db.collection("conversations")
            .whereField("participantIds", arrayContains: userId)
            .order(by: "lastMessageTimestamp", descending: true)
            .addSnapshotListener { snapshot, _ in
                let conversations = (snapshot?.documents ?? []).compactMap { try? $0.data(as: Conversation.self) }
                onUpdate(conversations)
            }
    }
}
