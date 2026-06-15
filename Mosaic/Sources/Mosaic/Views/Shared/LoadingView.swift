import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.mosaicBackground.ignoresSafeArea()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.mosaicAccent)
                .scaleEffect(1.5)
        }
    }
}
