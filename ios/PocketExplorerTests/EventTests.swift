import XCTest
@testable import PocketExplorer

@MainActor final class EventTests: XCTestCase {
    private let id = "77777777-7777-4777-8777-777777777777"
    private let cardID = "11111111-1111-4111-8111-111111111111"
    private var directory: URL!
    private var store: TripStore!
    private var session: URLSession!
    private let connection = ShareConnection(baseURL: "https://pocket.example", ownerKey: "pe1_" + String(repeating: "a", count: 64))
    private var event: ExplorerEvent {
        ExplorerEvent(id: id, revision: 1, title: "Sky watchers", description: "Discover the sky", language: "en", organizer: "Demo Nature Club", place: "Example park", location: ExplorerCoordinate(latitude: -33.86, longitude: 151.21), radius: 200, startsAt: Date.now.addingTimeInterval(-1000).timeIntervalSince1970 * 1000, endsAt: Date.now.addingTimeInterval(1000).timeIntervalSince1970 * 1000, minAge: 5, maxAge: 18, background: "stargazing", demonstration: true, challenge: .init(question: "What scatters light?", choices: ["Air", "Paint", "Moon"]), artworkPath: "/api/events/\(id)/artwork?language=en")
    }
    private var card: KnowledgeCard {
        let reply = AIReply(title: "Blue sky", answer: "Air scatters blue light.", invitation: "Look at the sky.", category: "science", artworkPrompt: "Blue sky", quiz: DiscoveryQuiz(question: event.challenge.question, choices: event.challenge.choices, correctIndex: 0, explanation: "Air scatters light."))
        let version = KnowledgeVersion(version: 1, explorationID: cardID, question: "Why is the sky blue?", language: "en", reply: reply, awardedAt: Date.now.timeIntervalSince1970 * 1000, artworkID: cardID, audience: "public")
        return KnowledgeCard(id: cardID, style: .forest, createdAt: version.awardedAt, updatedAt: version.awardedAt, tier: .common, versions: [version], origin: CardOrigin(kind: "event", sourceID: id, label: "Sky watchers"))
    }
    private var reading: LocationReading { LocationReading(coordinate: event.location, accuracy: 20, observedAt: .now) }
    private var shared: SharedMapCard { SharedMapCard(id: id, audience: .publicApproximate, location: event.location, publishedAt: Date.now.timeIntervalSince1970 * 1000, title: "Blue sky", question: "Why blue?", answer: "Air scatters blue.", category: "science", language: "en", version: 1, tier: .common, artworkPath: "/api/map-discoveries/\(id)/artwork") }
    override func setUp() async throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        store = try TripStore(fileURL: directory.appendingPathComponent("journal.json"), initial: JournalState(trips: [], discoveries: []))
        let config = URLSessionConfiguration.ephemeral; config.protocolClasses = [DiscoveryHTTPProtocol.self]; session = URLSession(configuration: config)
    }
    override func tearDown() async throws { session.invalidateAndCancel(); DiscoveryHTTPProtocol.respond = nil; try? FileManager.default.removeItem(at: directory) }
    private func respond<T: Encodable>(_ value: T, status: Int = 200) throws {
        let data = try JSONEncoder().encode(value)
        DiscoveryHTTPProtocol.respond = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.connection.ownerKey)")
            return (status, [:], data)
        }
    }
    func testLocationValidityEventWindowsAndImmutableReceivedCardPersistence() throws {
        let link = try XCTUnwrap(DiscoveryLink(url: URL(string: "pocketexplorer://events/\(id)")!))
        XCTAssertEqual(link.kind, "events"); XCTAssertEqual(link.id, "events/\(id)")
        for bad in ["https://events/\(id)", "pocketexplorer://events/\(id)?secret=1", "pocketexplorer://events/\(id)#extra", "pocketexplorer://events/bad", "pocketexplorer://wrong/\(id)"] { XCTAssertNil(DiscoveryLink(url: URL(string: bad)!)) }
        XCTAssertTrue(event.isValid); XCTAssertTrue(event.isActive()); XCTAssertFalse(event.isActive(now: .distantFuture))
        XCTAssertTrue(reading.isFresh()); XCTAssertEqual(event.meetingPlace.latitude, event.location.latitude)
        XCTAssertEqual(ExplorerCoordinate(latitude: -33.864321, longitude: 151.213456).approximate, ExplorerCoordinate(latitude: -33.86, longitude: 151.21))
        XCTAssertEqual(MapAudience.allCases.filter(\.needsLocation), [.friendsApproximate, .publicApproximate])
        XCTAssertEqual(MapAudience.allCases.filter(\.needsFriends), [.friendsOnly, .friendsApproximate])
        for value in [Double.nan, .infinity, -91, 91] { XCTAssertFalse(ExplorerCoordinate(latitude: value, longitude: 0).isValid) }
        var stale = reading; stale.observedAt = .distantPast; XCTAssertFalse(stale.isFresh())
        stale = reading; stale.accuracy = -1; XCTAssertFalse(stale.isFresh())
        stale = reading; stale.accuracy = 101; XCTAssertFalse(stale.isFresh())
        var invalid = event; invalid.challenge.choices = []; XCTAssertFalse(invalid.isValid)
        invalid = event; invalid.artworkPath = "https://bad.example"; XCTAssertFalse(invalid.isValid)
        var privateCard = card; privateCard.origin?.kind = "unknown"; XCTAssertFalse(privateCard.isValid)
        let value = card, found = try store.receiveCard(value, place: event.meetingPlace)
        XCTAssertTrue(found.isUnlocked); XCTAssertTrue(found.isVerified); XCTAssertEqual(found.origin, .exploration)
        XCTAssertEqual(try store.receiveCard(value).id, found.id)
        let restored = try TripStore(fileURL: store.fileURL)
        XCTAssertEqual(restored.state.discoveries.count, 1); XCTAssertEqual(restored.questions.first?.id, UUID(uuidString: cardID))
        XCTAssertEqual(restored.state.discoveries[0].collectible, value)
        XCTAssertThrowsError(try store.receiveCard(privateCard))
        var gift = value; gift.id = UUID().uuidString.lowercased(); gift.versions[0].explorationID = gift.id; gift.origin?.kind = "gift"
        XCTAssertEqual(try store.receiveCard(gift).origin, .gift)
    }
    func testClientReadsClaimsPublicationAndRevocationWithValidatedResponses() async throws {
        let client = EventClient(session: session), event = self.event
        let shared = self.shared
        try respond(shared); let linked = try await client.mapCard(id, connection: connection); XCTAssertEqual(linked, shared)
        DiscoveryHTTPProtocol.respond = { _ in (200, [:], Data([1, 2])) }
        let image = try await client.mapArtwork(shared, connection: connection); XCTAssertEqual(image, Data([1, 2]))
        var noArt = shared; noArt.artworkPath = nil; let noImage = try await client.mapArtwork(noArt, connection: connection); XCTAssertNil(noImage)
        try respond(NearbyEvents(items: [event], truncated: false))
        let nearby = try await client.nearby(event.location, language: "en", connection: connection); XCTAssertEqual(nearby.items, [event])
        try respond(event); let fetched = try await client.read(id, language: "en", connection: connection); XCTAssertEqual(fetched, event)
        let value = card
        try respond(EventClaim(correct: true, collectible: value))
        let result = try await client.claim(event, id: UUID(), choice: 0, reading: reading, connection: connection); XCTAssertEqual(result.collectible, value)
        try respond(NearbyCards(items: [shared], truncated: false))
        let cards = try await client.nearbyCards(event.location, connection: connection); XCTAssertEqual(cards.items[0].id, id)
        var friendCard = shared; friendCard.audience = .friendsOnly; friendCard.location = nil
        struct Friends: Encodable { var items: [SharedMapCard] }
        try respond(Friends(items: [friendCard])); XCTAssertEqual(try await client.friendCards(connection: connection), [friendCard])
        try respond(shared)
        DiscoveryHTTPProtocol.respond = { request in
            let body = try XCTUnwrap(request.httpBody), input = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
            XCTAssertEqual(input["audience"] as? String, "public_approximate")
            XCTAssertEqual((input["location"] as? [String: Double])?["latitude"], -33.86)
            return (200, [:], try JSONEncoder().encode(shared))
        }
        let publication = try await client.publish(cardID, audience: .publicApproximate, location: ExplorerCoordinate(latitude: -33.864321, longitude: 151.213456), connection: connection); XCTAssertTrue(publication.isValid)
        var publicCard = shared; publicCard.audience = .public; publicCard.location = nil
        DiscoveryHTTPProtocol.respond = { request in
            let body = try XCTUnwrap(request.httpBody), input = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
            XCTAssertEqual(input["audience"] as? String, "public"); XCTAssertNil(input["location"])
            return (200, [:], try JSONEncoder().encode(publicCard))
        }
        _ = try await client.publish(cardID, audience: .public, location: nil, connection: connection)
        struct Mine: Encodable { var items: [MapPublication] }
        try respond(Mine(items: [MapPublication(id: id, collectibleID: cardID, audience: .publicApproximate, latitude: -33.86, longitude: 151.21, revoked: 0)]))
        let mine = try await client.mine(connection: connection); XCTAssertEqual(mine[0].collectibleID, cardID)
        try respond(["ok": true], status: 204); try await client.revoke(id, connection: connection)
        for code in ["event_location_stale", "event_too_far", "event_changed", "event_not_active", "event_age_restricted", "event_language_unavailable", "family_required", "unknown"] {
            try respond(["error": code], status: 409)
            do { _ = try await client.read(id, language: "en", connection: connection); XCTFail("Must fail") } catch { XCTAssertFalse(error.localizedDescription.isEmpty) }
        }
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.cancelled) }
        do { _ = try await client.read(id, language: "en", connection: connection); XCTFail("Cancelled") } catch { XCTAssertTrue(error is CancellationError) }
        DiscoveryHTTPProtocol.respond = { _ in (200, [:], Data("bad".utf8)) }
        do { _ = try await client.read(id, language: "en", connection: connection); XCTFail("Invalid response") } catch {}
        do { _ = try await client.read("bad", language: "en", connection: connection); XCTFail("Invalid identifier") } catch {}
        do { _ = try await client.claim(event, id: UUID(), choice: 0, reading: LocationReading(coordinate: event.location, accuracy: 20, observedAt: .distantPast), connection: connection); XCTFail("Stale") } catch {}
    }
    func testCachedEventsAndRetryIDsPersistWithoutPersonalCoordinates() async throws {
        let events = EventStore(file: directory.appendingPathComponent("events-test.json"), client: EventClient(session: session)), value = event
        let catalog = try JSONEncoder().encode(NearbyEvents(items: [value], truncated: false))
        let cards = try JSONEncoder().encode(NearbyCards(items: [shared], truncated: true))
        DiscoveryHTTPProtocol.respond = { request in (200, [:], request.url!.path == "/api/events" ? catalog : cards) }
        await events.refresh(at: value.location, connection: connection)
        XCTAssertNil(events.error); XCTAssertTrue(events.truncated); XCTAssertFalse(events.busy)
        let restored = EventStore(file: directory.appendingPathComponent("events-test.json"))
        XCTAssertEqual(restored.events.map(\.id), events.events.map(\.id))
        DiscoveryHTTPProtocol.respond = { _ in throw URLError(.notConnectedToInternet) }
        await events.refresh(at: value.location, connection: connection)
        XCTAssertNotNil(events.error); XCTAssertTrue(events.shared.isEmpty)
        XCTAssertEqual(events.events.map(\.id), restored.events.map(\.id))
        do { _ = try await events.claim(value, choice: 0, reading: reading, store: store, connection: connection); XCTFail("Offline") } catch {}
        let state = try String(contentsOf: directory.appendingPathComponent("events-test.json"), encoding: .utf8)
        XCTAssertTrue(state.contains("attempts")); XCTAssertFalse(state.contains("observedAt")); XCTAssertFalse(state.contains("accuracy"))
        try respond(EventClaim(correct: true, collectible: card))
        let result = try await events.claim(value, choice: 0, reading: reading, store: store, connection: connection)
        XCTAssertTrue(result.correct); XCTAssertEqual(store.state.discoveries.count, 1)
        let broken = EventStore(file: directory.appendingPathComponent("broken.json"), client: EventClient(session: session), writer: { _, _ in throw CocoaError(.fileWriteNoPermission) })
        do { _ = try await broken.claim(value, choice: 0, reading: reading, store: store, connection: connection); XCTFail("Persistence must precede the request") } catch {}
    }
    func testEventStoreSeparatesNearbyAndFriendMapCards() async throws {
        let events = EventStore(file: directory.appendingPathComponent("map-groups.json"), client: EventClient(session: session))
        var friend = shared; friend.audience = .friendsApproximate
        struct Friends: Encodable { var items: [SharedMapCard] }
        let eventData = try JSONEncoder().encode(NearbyEvents(items: [event], truncated: false))
        let nearbyData = try JSONEncoder().encode(NearbyCards(items: [shared], truncated: false))
        let friendData = try JSONEncoder().encode(Friends(items: [friend]))
        DiscoveryHTTPProtocol.respond = { request in
            switch request.url!.path {
            case "/api/events": return (200, [:], eventData)
            case "/api/map-discoveries/friends": return (200, [:], friendData)
            default: return (200, [:], nearbyData)
            }
        }
        await events.refresh(at: event.location, includeFriends: true, connection: connection)
        XCTAssertEqual(events.nearbyShared, [shared])
        XCTAssertEqual(events.friendShared, [friend])
        XCTAssertEqual(events.shared.map(\.id), [shared.id])
    }
}
