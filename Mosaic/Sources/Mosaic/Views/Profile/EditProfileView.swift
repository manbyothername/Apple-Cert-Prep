import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: ProfileViewModel

    @State private var displayName: String
    @State private var ageText: String
    @State private var bio: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showVerificationStub = false

    init(user: AppUser) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
        _displayName = State(initialValue: user.displayName)
        _ageText = State(initialValue: "\(user.age)")
        _bio = State(initialValue: user.bio)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mosaicBackground.ignoresSafeArea()

                Form {
                    Section("Photos") {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("Add Photo", systemImage: "photo.badge.plus")
                        }
                        .onChange(of: selectedPhotoItem) { _, item in
                            Task {
                                if let data = try? await item?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    await viewModel.uploadPhoto(image, at: viewModel.user.photoURLs.count)
                                    // Sync change back to global auth state
                                    authViewModel.currentUser?.photoURLs = viewModel.user.photoURLs
                                }
                            }
                        }

                        ForEach(viewModel.user.photoURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.mosaicSurface
                                }
                                .frame(height: 180)
                                .clipped()
                                .cornerRadius(8)
                            }
                        }
                    }

                    Section("About") {
                        TextField("Display name", text: $displayName)
                        TextField("Age", text: $ageText)
                            .keyboardType(.numberPad)
                        TextField("Bio", text: $bio, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    Section("Verification") {
                        if viewModel.user.isVerified {
                            Label("Verified", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(.blue)
                        } else {
                            Button("Get Verified — Appear First in Discovery") {
                                showVerificationStub = true
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.updateProfile(
                                displayName: displayName,
                                age: Int(ageText) ?? 18,
                                bio: bio
                            )
                            // Sync changes to global auth state
                            authViewModel.currentUser?.displayName = viewModel.user.displayName
                            authViewModel.currentUser?.age = viewModel.user.age
                            authViewModel.currentUser?.bio = viewModel.user.bio
                            dismiss()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Verification Coming Soon", isPresented: $showVerificationStub) {
                Button("Got it") {}
            } message: {
                Text("AI-powered liveness verification is coming in a future update. You'll hold a sign with your username while facing the camera to prove you're real.")
            }
        }
    }
}
