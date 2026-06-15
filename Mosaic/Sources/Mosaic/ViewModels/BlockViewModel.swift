import Foundation

@MainActor
final class BlockViewModel: ObservableObject {
    @Published var showReasonPicker = false
    @Published var isBlocking = false
    @Published var error: String?

    private(set) var targetUserId: String?

    func initiateBlock(targetUserId: String) {
        self.targetUserId = targetUserId
        showReasonPicker = true
    }

    func confirmBlock(reason: BlockReason?, blockerId: String, onBlocked: (() -> Void)? = nil) async {
        guard let targetUserId else { return }
        isBlocking = true
        do {
            try await BlockService.shared.block(blockerId: blockerId, blockedId: targetUserId, reason: reason)
            onBlocked?()
        } catch {
            self.error = error.localizedDescription
        }
        isBlocking = false
        showReasonPicker = false
        self.targetUserId = nil
    }

    func dismiss() {
        showReasonPicker = false
        targetUserId = nil
    }
}
