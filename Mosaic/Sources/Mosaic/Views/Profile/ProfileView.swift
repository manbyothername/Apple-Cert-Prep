import SwiftUI

struct ProfileView: View {
    let user: AppUser
    @ObservedObject var blockViewModel: BlockViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var messagingViewModel = MessagingViewModel()
    @State private var conversationId: String?
    @State private var navigateToChat = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.mosaicBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero photo
                    if let url = user.photoURLs.first.flatMap(URL.init) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.mosaicSurface
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 360)
                        .clipped()
                    } else {
                        Color.mosaicSurface
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 72))
                                    .foregroundStyle(.secondary)
                            )
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(user.displayName)
                                .font(.title.bold())
                            Text("\(user.age)")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            if user.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(.blue)
                            }
                            Spacer()
                            if user.flaggedBlockCount > 0 {
                                BlockFlagBadgeView(count: user.flaggedBlockCount)
                            }
                        }

                        if !user.bio.isEmpty {
                            Text(user.bio)
                                .foregroundStyle(.secondary)
                        }

                        HStack(spacing: 12) {
                            Button {
                                Task {
                                    guard let uid = authViewModel.currentUser?.uid else { return }
                                    conversationId = await messagingViewModel.openConversation(
                                        with: user.uid, currentUserId: uid
                                    )
                                    navigateToChat = conversationId != nil
                                }
                            } label: {
                                Label("Message", systemImage: "message")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(MosaicPrimaryButtonStyle())

                            Button(role: .destructive) {
                                blockViewModel.initiateBlock(targetUserId: user.uid)
                            } label: {
                                Label("Block", systemImage: "hand.raised")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(MosaicDestructiveButtonStyle())
                        }

                        // Additional photos
                        if user.photoURLs.count > 1 {
                            Text("More Photos")
                                .font(.headline)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                                ForEach(user.photoURLs.dropFirst(), id: \.self) { urlString in
                                    if let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            Color.mosaicSurface
                                        }
                                        .aspectRatio(1, contentMode: .fill)
                                        .clipped()
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(user.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToChat) {
            if let convoId = conversationId, let currentUser = authViewModel.currentUser {
                ChatView(conversationId: convoId, currentUser: currentUser, otherUser: user)
            }
        }
        .onChange(of: blockViewModel.showReasonPicker) { _, showing in
            // Dismiss this view after a successful block so the user lands back on the grid
            if !showing && blockViewModel.targetUserId == nil {
                dismiss()
            }
        }
    }
}
