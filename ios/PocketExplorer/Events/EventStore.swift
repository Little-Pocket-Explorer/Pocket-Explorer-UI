import Foundation
import Observation

@MainActor @Observable
final class EventStore {
    private struct State: Codable {
        var events: [ExplorerEvent] = []
        var attempts: [String: UUID] = [:]
    }
    private var state: State
    private let file: URL
    private let write: (Data, URL) throws -> Void
    var client: EventClient
    private(set) var busy = false
    private(set) var error: String?
    private(set) var shared: [SharedMapCard] = []
    private(set) var truncated = false
    var events: [ExplorerEvent] { state.events.filter { $0.language == AppLanguage.current.rawValue } }

    init(file: URL, client: EventClient = EventClient(), writer: ((Data, URL) throws -> Void)? = nil) {
        self.file = file; self.client = client
        self.write = writer ?? { try $0.write(to: $1, options: .atomic) }
        if let data = try? Data(contentsOf: file), data.count < 4_000_000,
           let saved = try? JSONDecoder().decode(State.self, from: data), saved.events.allSatisfy(\.isValid) { state = saved }
        else { state = State() }
    }
    func refresh(at coordinate: ExplorerCoordinate, connection: ShareConnection) async {
        guard !busy else { return }
        busy = true; error = nil; defer { busy = false }
        do {
            let result = try await client.nearby(coordinate, language: AppLanguage.current.rawValue, connection: connection)
            var next = state; next.events = result.items
            try persist(next)
            let cards = try await client.nearbyCards(coordinate, connection: connection)
            shared = cards.items; truncated = result.truncated || cards.truncated
        } catch {
            shared = []
            if !(error is CancellationError) { self.error = error.localizedDescription }
        }
    }
    func claim(_ event: ExplorerEvent, choice: Int, reading: LocationReading, store: TripStore, connection: ShareConnection) async throws -> EventClaim {
        guard !busy, store.family.allows(.events) else { throw FamilyError.disabled }
        let key = "\(event.id):\(event.revision):\(choice)"
        var next = state
        let id = next.attempts[key] ?? UUID()
        next.attempts[key] = id
        try persist(next)
        busy = true; defer { busy = false }
        let result = try await client.claim(event, id: id, choice: choice, reading: reading, connection: connection)
        if let card = result.collectible { _ = try store.receiveCard(card, place: event.meetingPlace) }
        return result
    }
    private func persist(_ next: State) throws {
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try write(JSONEncoder().encode(next), file)
        state = next
    }
}
