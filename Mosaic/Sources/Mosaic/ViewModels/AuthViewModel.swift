import Foundation
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isLoading = true
    @Published var error: String?

    init() {
        _ = AuthService.shared.addAuthStateListener { [weak self] firebaseUser in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let firebaseUser {
                    self.currentUser = try? await UserService.shared.fetchUser(uid: firebaseUser.uid)
                } else {
                    self.currentUser = nil
                }
                self.isLoading = false
            }
        }
    }

    func signUp(email: String, password: String, displayName: String, age: Int) async {
        isLoading = true
        error = nil
        do {
            let firebaseUser = try await AuthService.shared.signUp(email: email, password: password)
            let user = AppUser(
                uid: firebaseUser.uid,
                displayName: displayName,
                age: age,
                bio: "",
                photoURLs: [],
                isVerified: false,
                flaggedBlockCount: 0,
                createdAt: Timestamp(date: Date())
            )
            try UserService.shared.createUser(user)
            currentUser = user
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        error = nil
        do {
            let firebaseUser = try await AuthService.shared.signIn(email: email, password: password)
            currentUser = try await UserService.shared.fetchUser(uid: firebaseUser.uid)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() {
        try? AuthService.shared.signOut()
        currentUser = nil
    }
}
