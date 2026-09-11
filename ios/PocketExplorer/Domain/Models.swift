import Foundation

enum DiscoverySubject: String, Codable, CaseIterable, Identifiable {
    case duck, leaf, shell

    var id: String { rawValue }
    var title: String {
        switch self {
        case .duck: return L10n.text("Duck paddles")
        case .leaf: return L10n.text("Leaf detectives")
        case .shell: return L10n.text("Tiny ocean homes")
        }
    }
    var category: String {
        switch self {
        case .duck: return L10n.text("Pond discovery")
        case .leaf: return L10n.text("Garden discovery")
        case .shell: return L10n.text("Coastal discovery")
        }
    }
    var sampleQuestion: String {
        switch self {
        case .duck: return L10n.text("How do ducks swim?")
        case .leaf: return L10n.text("Are all leaves the same?")
        case .shell: return L10n.text("Who lived in this shell?")
        }
    }
}

struct Place: Codable, Equatable, Identifiable {
    var name: String
    var latitude: Double
    var longitude: Double
    var id: String { name }

    static let sydney = Place(name: "Sydney", latitude: -33.871373, longitude: 151.212548)
    static let melbourne = Place(name: "Melbourne", latitude: -37.818086, longitude: 144.973070)
    static let brisbane = Place(name: "Brisbane", latitude: -27.453085, longitude: 153.033147)
    static let examples = [sydney, melbourne, brisbane]
}

enum DiscoveryOrigin: String, Codable, Equatable {
    case exploration
    case gift

    var title: String {
        switch self {
        case .exploration: return L10n.text("Exploration")
        case .gift: return L10n.text("Gift")
        }
    }
}

enum CardTier: String, Codable, Equatable {
    case fieldFind

    var title: String { L10n.text("Field find") }
}

struct Discovery: Codable, Equatable, Identifiable {
    var id: UUID
    var tripID: UUID
    var subject: DiscoverySubject
    var question: String
    var observation: String
    var explanation: String
    var createdAt: Date
    var photoFilename: String?
    var unlockedAt: Date? = nil
    var origin: DiscoveryOrigin? = nil
    var tier: CardTier? = nil
}

struct MemoryChapter: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var text: String
    var subject: DiscoverySubject
}

struct TripMemory: Codable, Equatable, Identifiable {
    var id: UUID
    var chapters: [MemoryChapter]
}

struct Trip: Codable, Equatable, Identifiable {
    var id: UUID
    var title: String
    var startedAt: Date
    var place: Place?
    var completedAt: Date?
    var memory: TripMemory?
    var dismissedUntil: Date?
    var isExample: Bool
}

struct JournalState: Codable, Equatable {
    var version = 1
    var trips: [Trip]
    var discoveries: [Discovery]

    static func examples(now: Date = Date()) -> JournalState {
        let pond = UUID(uuidString: "10000000-0000-4000-8000-000000000001")!
        let garden = UUID(uuidString: "10000000-0000-4000-8000-000000000002")!
        let coast = UUID(uuidString: "10000000-0000-4000-8000-000000000003")!
        let old = now.addingTimeInterval(-9 * 86_400)
        let records = [
            Discovery(id: UUID(uuidString: "20000000-0000-4000-8000-000000000001")!, tripID: pond, subject: .duck, question: "How do ducks swim?", observation: "Their feet push the water like little paddles!", explanation: "Webbed feet help ducks push against the water.", createdAt: old),
            Discovery(id: UUID(uuidString: "20000000-0000-4000-8000-000000000002")!, tripID: pond, subject: .leaf, question: "Are all leaves the same?", observation: "One had smooth edges. Another had tiny teeth.", explanation: "Leaf shapes and edges can help us notice differences between plants.", createdAt: old.addingTimeInterval(600)),
            Discovery(id: UUID(uuidString: "20000000-0000-4000-8000-000000000003")!, tripID: garden, subject: .leaf, question: "Why does this leaf have lines?", observation: "The little lines branch out like roads.", explanation: "Leaf veins carry water and other materials through the leaf.", createdAt: old),
            Discovery(id: UUID(uuidString: "20000000-0000-4000-8000-000000000004")!, tripID: coast, subject: .shell, question: "Who lived in this shell?", observation: "I could see a little doorway and a spiral.", explanation: "Many molluscs grow shells that protect their soft bodies.", createdAt: old)
        ]
        let trips = [(pond, "The day we met the ducks", Place.sydney), (garden, "A garden full of little wonders", Place.melbourne), (coast, "Treasures by the sea", Place.brisbane)].map { id, title, place in
            Trip(id: id, title: title, startedAt: old, place: place, completedAt: old.addingTimeInterval(3600), memory: MemoryBuilder.build(tripID: id, discoveries: records.filter { $0.tripID == id }), isExample: true)
        }
        return JournalState(trips: trips, discoveries: records)
    }
}

enum JournalError: LocalizedError, Equatable {
    case emptyObservation, emptyQuestion, missingTrip, missingDiscovery, emptyTrip, invalidVersion

    var errorDescription: String? {
        switch self {
        case .emptyObservation: return "Tell us one thing you noticed first."
        case .emptyQuestion: return "Add your question first."
        case .missingTrip: return "This adventure could not be found."
        case .missingDiscovery: return "This discovery could not be found."
        case .emptyTrip: return "Make one discovery before creating a memory."
        case .invalidVersion: return "This journal needs a newer version of Pocket Explorer."
        }
    }
}
