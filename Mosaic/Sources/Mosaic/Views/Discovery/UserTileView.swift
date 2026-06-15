import SwiftUI

struct UserTileView: View {
    let user: AppUser

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let url = user.photoURLs.first.flatMap(URL.init) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.mosaicSurface
                }
            } else {
                Color.mosaicSurface
                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Name + badge row overlaid on image
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.blue)
                            .font(.caption2)
                    }
                    if user.flaggedBlockCount > 0 {
                        BlockFlagBadgeView(count: user.flaggedBlockCount)
                    }
                }
                Text(user.displayName)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .padding(6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .clipped()
        .opacity(user.hasPhoto ? 1.0 : 0.6)
    }
}
