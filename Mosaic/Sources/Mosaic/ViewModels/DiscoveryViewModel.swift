import Foundation

@MainActor
final class DiscoveryViewModel: ObservableObject {
    @Published var users: [AppUser] = []
    @Published var isLoading = false
    @Published var error: String?

    func load(currentUserId: String) async {
        isLoading = true
        error = nil
        do {
            let blockedIds = try await BlockService.shared.fetchBlockedIds(for: currentUserId)
            let excluded = blockedIds.union([currentUserId])
            users = try await UserService.shared.fetchDiscoveryUsers(excludingIds: Array(excluded))
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
