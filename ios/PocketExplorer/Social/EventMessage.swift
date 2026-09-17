import Foundation

struct EventMessage: Equatable {
    let eventID: String
    let title: String
    let url: URL

    init(event: ExplorerEvent, base: URL) {
        eventID = event.id
        title = event.title
        url = base.appendingPathComponent("events/\(event.id)")
    }

    init?(text: String, base: URL) {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.count == 2, !lines[0].isEmpty,
              let url = URL(string: String(lines[1])), url.scheme == base.scheme,
              url.host == base.host, url.port == base.port, url.user == nil, url.password == nil,
              url.query == nil, url.fragment == nil else { return nil }
        let prefix = base.appendingPathComponent("events").path + "/"
        guard url.path.hasPrefix(prefix) else { return nil }
        let identifier = String(url.path.dropFirst(prefix.count))
        guard UUID(uuidString: identifier) != nil, url.path == prefix + identifier,
              url.absoluteString == base.appendingPathComponent("events/\(identifier)").absoluteString else { return nil }
        eventID = identifier.lowercased(); title = String(lines[0]); self.url = url
    }

    var text: String { title.replacingOccurrences(of: "\n", with: " ") + "\n" + url.absoluteString }
}

struct FriendActivity: Identifiable, Equatable {
    enum Kind { case discovery, growth, gift, exchange }
    let card: KnowledgeCard
    var id: String { card.id }
    var date: Date { Date(timeIntervalSince1970: max(card.createdAt, card.versions.last?.awardedAt ?? 0) / 1000) }
    var kind: Kind {
        if card.versions.count > 1, let latest = card.versions.last, latest.awardedAt > card.createdAt { return .growth }
        if card.origin?.kind == "gift" { return .gift }
        if card.origin?.kind == "exchange" { return .exchange }
        return .discovery
    }
    var label: String {
        switch kind {
        case .discovery: L10n.text("A new card")
        case .growth: L10n.text("Growing knowledge")
        case .gift: L10n.text("A discovery gift")
        case .exchange: L10n.text("A card exchange")
        }
    }
    static func recent(_ cards: [KnowledgeCard]) -> [Self] {
        cards.filter { !$0.versions.isEmpty && $0.versions.allSatisfy { $0.audience == "public" } }.map { Self(card: $0) }
            .sorted { $0.date == $1.date ? $0.id < $1.id : $0.date > $1.date }
    }
}
