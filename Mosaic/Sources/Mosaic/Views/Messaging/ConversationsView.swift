import SwiftUI

struct ConversationsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = MessagingViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mosaicBackground.ignoresSafeArea()

                if viewModel.conversations.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "message")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No conversations yet")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Open someone's profile and tap Message to start chatting")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List(viewModel.conversations) { conversation in
                        ConversationRowView(
                            conversation: conversation,
                            currentUserId: authViewModel.currentUser?.uid ?? ""
                        )
                        .listRowBackground(Color.mosaicSurface)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Messages")
            .onAppear {
                guard let uid = authViewModel.currentUser?.uid else { return }
                viewModel.startListeningToConversations(userId: uid)
            }
            .onDisappear {
                viewModel.stopListening()
            }
        }
    }
}

private struct ConversationRowView: View {
    let conversation: Conversation
    let currentUserId: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.mosaicBackground)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.otherParticipantId(currentUserId: currentUserId) ?? "Unknown")
                    .font(.headline)
                if !conversation.lastMessage.isEmpty {
                    Text(conversation.lastMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if conversation.unreadCount > 0 {
                Text("\(conversation.unreadCount)")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(Color.mosaicAccent)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 4)
    }
}
