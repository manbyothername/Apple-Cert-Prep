import SwiftUI

struct OwnProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mosaicBackground.ignoresSafeArea()

                if let user = authViewModel.currentUser {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Avatar
                            if let url = user.photoURLs.first.flatMap(URL.init) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.mosaicSurface
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.mosaicSurface)
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 48))
                                            .foregroundStyle(.secondary)
                                    )
                            }

                            VStack(spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(user.displayName)
                                        .font(.title2.bold())
                                    if user.isVerified {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundStyle(.blue)
                                    }
                                }
                                Text("Age \(user.age)")
                                    .foregroundStyle(.secondary)
                            }

                            if !user.bio.isEmpty {
                                Text(user.bio)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            if !user.isVerified {
                                VStack(spacing: 8) {
                                    Image(systemName: "checkmark.seal")
                                        .font(.title)
                                        .foregroundStyle(Color.mosaicAccent)
                                    Text("Get Verified")
                                        .font(.headline)
                                    Text("Verified profiles appear first in discovery")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.mosaicSurface)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }

                            Button("Edit Profile") {
                                showEditProfile = true
                            }
                            .buttonStyle(MosaicPrimaryButtonStyle())
                            .padding(.horizontal)

                            Button("Sign Out", role: .destructive) {
                                authViewModel.signOut()
                            }
                            .foregroundStyle(.red)
                        }
                        .padding(.vertical)
                    }
                } else {
                    LoadingView()
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showEditProfile) {
                if let user = authViewModel.currentUser {
                    EditProfileView(user: user)
                }
            }
        }
    }
}
