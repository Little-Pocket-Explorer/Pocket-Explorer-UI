import SwiftUI

struct DiscoveryLink: Identifiable, Equatable {
    var kind: String
    var identifier: String
    var id: String { "\(kind)/\(identifier)" }
    init(kind: String, identifier: String) { self.kind = kind; self.identifier = identifier }
    init?(url: URL) {
        let pieces = url.pathComponents.filter { $0 != "/" }
        guard url.scheme == "pocketexplorer", let host = url.host, ["events", "discoveries"].contains(host),
              pieces.count == 1, UUID(uuidString: pieces[0]) != nil, url.query == nil, url.fragment == nil else { return nil }
        kind = host; identifier = pieces[0].lowercased()
    }
}

struct DiscoveryLinkView: View {
    let store: TripStore
    let link: DiscoveryLink
    @State private var event: ExplorerEvent?
    @State private var card: SharedMapCard?
    @State private var error: String?
    @State private var attempt = 0
    @Environment(\.explorerNavigation) private var navigation
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Group {
            if let event { EventDetailView(store: store, event: event) }
            else if let card { SharedMapCardView(card: card) }
            else {
                FeatureNavigation {
                    VStack(spacing: 20) {
                        LeafBadge(symbol: "map.fill")
                        if let error { Text(error).multilineTextAlignment(.center); Button("Try again") { attempt += 1 } }
                        else { ProgressView("Opening your little world…") }
                    }.padding(25).frame(maxWidth: .infinity, maxHeight: .infinity).background(ExplorerBackdrop())
                        .toolbar { Button("Done") { if let navigation { navigation.back() } else { dismiss() } } }
                }
            }
        }.overlay { if store.family.timeFinished { FamilyPauseView(family: store.family) } }
            .task(id: attempt) {
                error = nil
                do {
                    let connection = try ConnectionVault().loadOrCreate()
                    if link.kind == "events" { event = try await EventClient().read(link.identifier, language: AppLanguage.current.rawValue, connection: connection) }
                    else { card = try await EventClient().mapCard(link.identifier, connection: connection) }
                } catch { self.error = error.localizedDescription }
            }
    }
}
