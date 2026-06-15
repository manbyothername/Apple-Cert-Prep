import SwiftUI

struct BlockFlagBadgeView: View {
    let count: Int

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "flag.fill")
            Text("\(count)")
        }
        .font(.caption2.bold())
        .foregroundStyle(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.orange)
        .clipShape(Capsule())
    }
}
