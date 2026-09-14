import SwiftUI

enum Theme {
    static let ink = Color(hex: 0x193E38)
    static let muted = Color(hex: 0x61746B)
    static let paper = Color(hex: 0xFFFDF4)
    static let surface = Color(hex: 0xF0F1DF)
    static let forest = Color(hex: 0x176D56)
    static let ocean = Color(hex: 0xCCEAE3)
    static let land = Color(hex: 0xE1E8B7)
    static let line = Color(hex: 0xC8D79B)
    static let sun = Color(hex: 0xFFD76B)
    static let mint = Color(hex: 0xD9F9EC)
    static let shimmer = LinearGradient(colors: [Color(hex: 0xD1EED7), Color(hex: 0xF8D999), Color(hex: 0xF4BFAE), Color(hex: 0xE2D8FC), Color(hex: 0xADE3D3)], startPoint: .topLeading, endPoint: .bottomTrailing)
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 255) / 255, green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255, opacity: 1)
    }
}

struct ExplorerButtonStyle: ButtonStyle {
    var secondary = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, design: .rounded, weight: .bold))
            .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(LinearGradient(colors: secondary ? [Color.white, Theme.mint.opacity(0.4)] : [Color(hex: 0xBEFCE1), Color(hex: 0x68DDB3)], startPoint: .top, endPoint: .bottom), in: Capsule())
            .foregroundStyle(Theme.ink)
            .shadow(color: Theme.forest.opacity(configuration.isPressed ? 0 : 0.1), radius: 8, y: 4)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct Eyebrow: View {
    let text: String
    var body: some View {
        Text(L10n.text(text).uppercased()).font(.system(.caption2, design: .rounded, weight: .bold))
            .kerning(AppLanguage.current.isRightToLeft ? 0 : 2).foregroundStyle(Theme.muted)
            .accessibilityLabel(Text(L10n.text(text)))
    }
}
