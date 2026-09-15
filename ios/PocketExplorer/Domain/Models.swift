import Foundation

enum DiscoverySubject: String, Codable, CaseIterable, Identifiable {
    case duck, leaf, shell, discovery

    var id: String { rawValue }
    var title: String { title(language: .current) }
    func title(language: AppLanguage) -> String {
        switch self {
        case .duck: return L10n.text("Duck paddles", language: language)
        case .leaf: return L10n.text("Leaf detectives", language: language)
        case .shell: return L10n.text("Tiny ocean homes", language: language)
        case .discovery: return L10n.text("A new discovery", language: language)
        }
    }
    var category: String {
        switch self {
        case .duck: return L10n.text("Pond discovery")
        case .leaf: return L10n.text("Garden discovery")
        case .shell: return L10n.text("Coastal discovery")
        case .discovery: return L10n.text("Discovery")
        }
    }
    var sampleQuestion: String {
        switch self {
        case .duck: return L10n.text("How do ducks swim?")
        case .leaf: return L10n.text("Are all leaves the same?")
        case .shell: return L10n.text("Who lived in this shell?")
        case .discovery: return L10n.text("Why is the sky blue?")
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
    case common, rare, epic

    var title: String { L10n.text(self == .fieldFind ? "Field find" : rawValue.capitalized) }
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
    var ai: AIReply? = nil
    var explorationID: UUID? = nil
    var artwork: ArtworkJob? = nil
    var artworkFilename: String? = nil
    var quizAnsweredAt: Date? = nil
    var quizChoice: Int? = nil
    var place: Place? = nil
    var language: String? = nil
    var unlockRequired: Bool? = nil
    var collectible: KnowledgeCard? = nil
    var evolvesFrom: String? = nil

    var isUnlocked: Bool { unlockRequired != true || unlockedAt != nil }
    var isVerified: Bool {
        unlockRequired != true || collectible?.versions.contains(where: { $0.explorationID == explorationID?.uuidString.lowercased() }) == true
    }
    var collectionID: String { evolvesFrom ?? explorationID?.uuidString.lowercased() ?? id.uuidString.lowercased() }
    var cardVersion: Int { collectible?.versions.first(where: { $0.explorationID == explorationID?.uuidString.lowercased() })?.version ?? 1 }

    var title: String { ai?.title ?? subject.title(language: language.flatMap(AppLanguage.init(rawValue:)) ?? .current) }
    var category: String { ai.map { L10n.text($0.category.capitalized) } ?? subject.category }
    var categoryID: String {
        if let ai { return ai.category }
        switch subject {
        case .duck, .shell: return "animals"
        case .leaf: return "nature"
        case .discovery: return "science"
        }
    }
}

struct MemoryChapter: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var text: String
    var subject: DiscoverySubject
    var language: String? = nil
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
    var language: String? = nil
}

struct JournalState: Codable, Equatable {
    var version = 1
    var trips: [Trip]
    var discoveries: [Discovery]
    var explorations: [ExplorationRecord]? = nil
    var recallAttempts: [RecallAttempt]? = nil

    static func examples(now: Date = Date(), language: AppLanguage = .current) -> JournalState {
        func text(_ key: String) -> String { L10n.text(key, language: language) }
        let pond = UUID(uuidString: "10000000-0000-4000-8000-000000000001")!
        let garden = UUID(uuidString: "10000000-0000-4000-8000-000000000002")!
        let coast = UUID(uuidString: "10000000-0000-4000-8000-000000000003")!
        let old = now.addingTimeInterval(-9 * 86_400)
        let records = [
            Discovery(id: UUID(uuidString: "20000000-0000-4000-8000-000000000001")!, tripID: pond, subject: .duck, question: text("How do ducks swim?"), observation: text("Their feet push the water like little paddles!"), explanation: text("Webbed feet help ducks push against the water."), createdAt: old, language: language.rawValue),
            Discovery(id: UUID(uuidString: "20000000-0000-4000-8000-000000000002")!, tripID: pond, subject: .leaf, question: text("Are all leaves the same?"), observation: text("One had smooth edges. Another had tiny teeth."), explanation: text("Leaf shapes and edges can help us notice differences between plants."), createdAt: old.addingTimeInterval(600), language: language.rawValue),
            Discovery(id: UUID(uuidString: "20000000-0000-4000-8000-000000000003")!, tripID: garden, subject: .leaf, question: text("Why does this leaf have lines?"), observation: text("The little lines branch out like roads."), explanation: text("Leaf veins carry water and other materials through the leaf."), createdAt: old, language: language.rawValue),
            Discovery(id: UUID(uuidString: "20000000-0000-4000-8000-000000000004")!, tripID: coast, subject: .shell, question: text("Who lived in this shell?"), observation: text("I could see a little doorway and a spiral."), explanation: text("Many molluscs grow shells that protect their soft bodies."), createdAt: old, language: language.rawValue)
        ]
        let trips = [(pond, text("The day we met the ducks"), Place.sydney), (garden, text("A garden full of little wonders"), Place.melbourne), (coast, text("Treasures by the sea"), Place.brisbane)].map { id, title, place in
            Trip(id: id, title: title, startedAt: old, place: place, completedAt: old.addingTimeInterval(3600), memory: MemoryBuilder.build(tripID: id, discoveries: records.filter { $0.tripID == id }), isExample: true, language: language.rawValue)
        }
        return JournalState(trips: trips, discoveries: records)
    }
}

enum JournalError: LocalizedError, Equatable {
    case emptyObservation, emptyQuestion, missingTrip, missingDiscovery, emptyTrip, invalidVersion

    var errorDescription: String? {
        switch self {
        case .emptyObservation: return L10n.text("Tell us one thing you noticed first.")
        case .emptyQuestion: return L10n.text("Add your question first.")
        case .missingTrip: return L10n.text("This adventure could not be found.")
        case .missingDiscovery: return L10n.text("This discovery could not be found.")
        case .emptyTrip: return L10n.text("Make one discovery before creating a memory.")
        case .invalidVersion: return L10n.text("This journal needs a newer version of Pocket Explorer.")
        }
    }
}
