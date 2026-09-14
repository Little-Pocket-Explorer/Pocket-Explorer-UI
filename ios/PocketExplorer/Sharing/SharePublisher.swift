import Foundation

@MainActor
final class SharePublisher {
    struct Publication {
        let story: PublicStory
        let task: Task<PublishedShare, Error>
    }
    static let shared = SharePublisher()
    private let preferences: UserDefaults
    private let client: ShareClient
    private let connection: () throws -> ShareConnection
    private var requests: [String: Publication] = [:]
    private var revocations: [String: Task<Void, Error>] = [:]

    init(preferences: UserDefaults = ShareStorageScope.preferences, client: ShareClient = ShareClient(),
         connection: @escaping () throws -> ShareConnection = { try ConnectionVault().loadOrCreate() }) {
        self.preferences = preferences
        self.client = client
        self.connection = connection
    }

    func saved(for key: String) -> PublishedShare? {
        guard let data = preferences.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(PublishedShare.self, from: data)
    }

    func pending(for key: String) -> Publication? { requests[key] }
    func pendingRevocation(for key: String) -> Task<Void, Error>? { revocations[key] }

    func revoke(_ published: PublishedShare, key: String) -> Task<Void, Error> {
        if let request = revocations[key] { return request }
        let request = Task { @MainActor in
            defer { revocations[key] = nil }
            try await client.revoke(published.receipt, connection: connection())
            preferences.removeObject(forKey: key)
            guard preferences.object(forKey: key) == nil else { throw ShareError.unavailable }
        }
        revocations[key] = request
        return request
    }

    func publish(_ story: PublicStory, key: String) -> Publication {
        if let saved = saved(for: key) { return Publication(story: saved.story, task: Task { saved }) }
        if let request = requests[key] { return request }
        // Navigation may cancel a waiting view, but the receipt must still be saved.
        let task = Task { @MainActor in
            defer { requests[key] = nil }
            let receipt = try await client.create(story, connection: connection())
            let published = PublishedShare(receipt: receipt, story: story)
            let data = try JSONEncoder().encode(published)
            preferences.set(data, forKey: key)
            guard preferences.data(forKey: key) == data else { throw ShareError.unavailable }
            return published
        }
        let request = Publication(story: story, task: task)
        requests[key] = request
        return request
    }
}
