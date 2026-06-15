import Foundation
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: AppUser
    @Published var isLoading = false
    @Published var error: String?

    init(user: AppUser) {
        self.user = user
    }

    func updateProfile(displayName: String, age: Int, bio: String) async {
        isLoading = true
        user.displayName = displayName
        user.age = age
        user.bio = bio
        do {
            try UserService.shared.updateUser(user)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func uploadPhoto(_ image: UIImage, at index: Int) async {
        isLoading = true
        do {
            let url = try await StorageService.shared.uploadProfilePhoto(image, userId: user.uid, index: index)
            if index < user.photoURLs.count {
                user.photoURLs[index] = url
            } else {
                user.photoURLs.append(url)
            }
            try UserService.shared.updateUser(user)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
