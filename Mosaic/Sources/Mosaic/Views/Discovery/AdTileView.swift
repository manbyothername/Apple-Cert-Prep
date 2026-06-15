import SwiftUI

// Banner-height ad slot. Phase 2: replace body with GADBannerView UIViewRepresentable.
struct AdTileView: View {
    var body: some View {
        ZStack {
            Color.mosaicSurface
            HStack {
                Text("Ad")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.leading, 8)
                Spacer()
                Text("Advertisement placeholder")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .cornerRadius(4)
    }
}
