import SwiftUI

struct ExplorerBackdrop: View {
    var body: some View {
        LinearGradient(colors: [Color(hex: 0xE8F7FC), .white, Color(hex: 0xF0FAEE)], startPoint: .top, endPoint: .bottom)
            .overlay(alignment: .bottom) {
                Image("explorer-meadow").resizable().scaledToFit().opacity(0.85)
            }.ignoresSafeArea().accessibilityHidden(true)
    }
}

struct ExplorerAvatar: View {
    var size: CGFloat = 42
    var body: some View {
        Image("explorer-avatar").resizable().scaledToFill().frame(width: size, height: size)
            .clipShape(Circle()).overlay(Circle().stroke(.white, lineWidth: 3))
            .shadow(color: Theme.forest.opacity(0.1), radius: 5, y: 2).accessibilityHidden(true)
    }
}

struct LeafBadge: View {
    var symbol = "leaf.fill"
    var body: some View {
        Image(systemName: symbol).font(.system(size: 20, weight: .semibold)).foregroundStyle(Theme.forest)
            .frame(width: 38, height: 38).background(Theme.mint, in: Circle()).accessibilityHidden(true)
    }
}

struct BotanicalFrame: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.paper, in: RoundedRectangle(cornerRadius: 24))
            .padding(5)
            .background(LinearGradient(colors: [.white, Color(hex: 0xFFF1B5), .white, Color(hex: 0xE7F3B7)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 29))
            .overlay(RoundedRectangle(cornerRadius: 29).stroke(Color(hex: 0xE8CC71), lineWidth: 1.5))
            .overlay(alignment: .topTrailing) {
                Image(systemName: "leaf.fill").font(.system(size: 19)).rotationEffect(.degrees(90))
                    .foregroundStyle(Color(hex: 0x84B84B)).padding(10).accessibilityHidden(true)
            }
            .shadow(color: Color(hex: 0x536D35).opacity(0.12), radius: 12, y: 6)
    }
}

struct DiscoveryArtwork: View {
    let discovery: Discovery
    var store: TripStore?
    var body: some View {
        Group {
            if let filename = discovery.artworkFilename, let store,
               let data = try? Data(contentsOf: store.mediaURL(filename)), let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
            } else if discovery.ai != nil {
                ZStack {
                    LinearGradient(colors: [Theme.mint, Color(hex: 0xEAF8FE), Theme.paper], startPoint: .topLeading, endPoint: .bottomTrailing)
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.fill").font(.system(size: 48, weight: .light)).foregroundStyle(Theme.forest.opacity(0.7))
                        Text(L10n.text(discovery.artwork?.status == "failed" ? "Your discovery is safe" : "Growing your illustration…"))
                            .font(.system(.caption, design: .rounded, weight: .semibold)).multilineTextAlignment(.center)
                    }.padding()
                }
            } else {
                Image(discovery.subject.rawValue).resizable().scaledToFit()
            }
        }.accessibilityLabel(discovery.title)
    }
}
