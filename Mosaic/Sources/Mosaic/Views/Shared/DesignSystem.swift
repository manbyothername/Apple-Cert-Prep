import SwiftUI

extension Color {
    static let mosaicBackground = Color(red: 0.07, green: 0.07, blue: 0.10)
    static let mosaicSurface = Color(red: 0.13, green: 0.13, blue: 0.18)
    static let mosaicAccent = Color(red: 0.40, green: 0.20, blue: 0.90)
}

extension View {
    func mosaicTextField() -> some View {
        self
            .padding()
            .background(Color.mosaicSurface)
            .cornerRadius(12)
            .foregroundStyle(.primary)
    }
}

struct MosaicPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.mosaicAccent.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .cornerRadius(12)
    }
}

struct MosaicDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.red.opacity(configuration.isPressed ? 0.7 : 0.9))
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .cornerRadius(12)
    }
}
