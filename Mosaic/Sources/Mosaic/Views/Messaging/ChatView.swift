import SwiftUI

struct ChatView: View {
    let conversationId: String
    let currentUser: AppUser
    let otherUser: AppUser

    @StateObject private var viewModel = MessagingViewModel()
    @State private var messageText = ""

    var body: some View {
        ZStack {
            Color.mosaicBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(
                                    message: message,
                                    isOwn: message.senderId == currentUser.uid
                                )
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastId = viewModel.messages.last?.id {
                            withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                        }
                    }
                }

                Divider()

                HStack(spacing: 12) {
                    TextField("Message \(otherUser.displayName)…", text: $messageText, axis: .vertical)
                        .lineLimit(1...4)
                        .mosaicTextField()

                    Button {
                        let text = messageText
                        messageText = ""
                        Task {
                            await viewModel.send(
                                text: text,
                                conversationId: conversationId,
                                senderId: currentUser.uid
                            )
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                messageText.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? .secondary : Color.mosaicAccent
                            )
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
                .background(Color.mosaicSurface)
            }
        }
        .navigationTitle(otherUser.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startListeningToMessages(conversationId: conversationId)
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}

private struct MessageBubbleView: View {
    let message: Message
    let isOwn: Bool

    var body: some View {
        HStack {
            if isOwn { Spacer(minLength: 60) }
            Text(message.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isOwn ? Color.mosaicAccent : Color.mosaicSurface)
                .foregroundStyle(isOwn ? .white : .primary)
                .cornerRadius(18)
            if !isOwn { Spacer(minLength: 60) }
        }
    }
}
