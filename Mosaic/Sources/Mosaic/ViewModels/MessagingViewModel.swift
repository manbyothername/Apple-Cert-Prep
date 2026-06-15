import Foundation
import FirebaseFirestore

@MainActor
final class MessagingViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var messages: [Message] = []

    private var conversationsListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?

    func startListeningToConversations(userId: String) {
        conversationsListener = MessagingService.shared.conversationsListener(userId: userId) { [weak self] updated in
            Task { @MainActor [weak self] in self?.conversations = updated }
        }
    }

    func startListeningToMessages(conversationId: String) {
        messagesListener = MessagingService.shared.messagesListener(conversationId: conversationId) { [weak self] updated in
            Task { @MainActor [weak self] in self?.messages = updated }
        }
    }

    func openConversation(with userId: String, currentUserId: String) async -> String? {
        do {
            let conversation = try await MessagingService.shared.fetchOrCreateConversation(between: currentUserId, and: userId)
            return conversation.id
        } catch {
            return nil
        }
    }

    func send(text: String, conversationId: String, senderId: String) async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        try? await MessagingService.shared.sendMessage(conversationId: conversationId, senderId: senderId, text: text)
    }

    func stopListening() {
        conversationsListener?.remove()
        messagesListener?.remove()
    }
}
