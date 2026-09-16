import Foundation
import Observation

struct AccountRemovalClient {
    var session: URLSession = NarrationClient.session

    func delete(connection: ShareConnection, parent: String?) async throws {
        guard let base = connection.validatedURL else { throw ShareError.configuration }
        var request = URLRequest(url: base.appendingPathComponent("api/account/delete"), timeoutInterval: 60)
        request.httpMethod = "POST"
        request.httpBody = Data("{\"confirm\":\"delete\"}".utf8)
        request.setValue("Bearer \(connection.ownerKey)", forHTTPHeaderField: "Authorization")
        request.setValue(parent, forHTTPHeaderField: "x-parent-session")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw FamilyError.invalidResponse }
        if http.statusCode == 403 { throw FamilyError.parentRequired }
        struct Result: Decodable { var deleted: Bool }
        guard http.statusCode == 200, let result = try? JSONDecoder().decode(Result.self, from: data), result.deleted else {
            throw FamilyError.unavailable
        }
    }
}

@MainActor @Observable final class AccountRemoval {
    private let preferences: UserDefaults
    private let vault: ConnectionVault
    private let client: AccountRemovalClient
    private let clean: (URL) throws -> Void
    private var prepared = false
    private var parent: String?
    private var file = TripStore.defaultURL
    private(set) var active: Bool
    private(set) var busy = false
    private(set) var finished = false
    private(set) var error: String?
    var unlockMessage = false
    static let key = "account-removal"

    init(preferences: UserDefaults = ShareStorageScope.preferences, vault: ConnectionVault = ConnectionVault(),
         client: AccountRemovalClient = AccountRemovalClient(), clean: ((URL) throws -> Void)? = nil) {
        self.preferences = preferences; self.vault = vault; self.client = client
        self.clean = clean ?? Self.eraseFiles
        active = preferences.string(forKey: Self.key) != nil
    }

    func prepareOnLaunch(file: URL) throws {
        guard !prepared else { return }
        self.file = file
        active = preferences.string(forKey: Self.key) != nil
        if preferences.string(forKey: Self.key) == "completed" {
            // Repeat cleanup on a fresh process so late callbacks from the old session cannot restore data.
            try clean(file)
            try vault.erase()
            clearPreferences()
            preferences.removeObject(forKey: Self.key)
            active = false
        }
        prepared = true
    }

    func start(parent: String?) async {
        guard !active else { return }
        self.parent = parent
        preferences.set("requested", forKey: Self.key)
        active = true
        await resume()
    }

    func resume() async {
        guard active, !busy, !finished else { return }
        busy = true; error = nil
        defer { busy = false }
        do {
            if preferences.string(forKey: Self.key) != "completed" {
                let connection = try vault.read()
                if let connection { try await client.delete(connection: connection, parent: parent) }
                preferences.set("completed", forKey: Self.key)
            }
            await RecallNotifications.shared.setEnabled(false)
            URLCache.shared.removeAllCachedResponses()
            try clean(file)
            clearPreferences()
            // Keep the revoked credential until the next launch for crash-safe deletion retries.
            parent = nil; finished = true
        } catch FamilyError.parentRequired {
            parent = nil
            preferences.removeObject(forKey: Self.key)
            active = false; unlockMessage = true
        } catch {
            self.error = L10n.text("Deletion could not finish. Your request is saved. Please try again when online.")
        }
    }

    private func clearPreferences() {
        for key in preferences.dictionaryRepresentation().keys where key.hasPrefix("share-") || key.hasPrefix("ai-data-permission.") || ["explorer-profile", "explorer-age", "recall-notifications"].contains(key) {
            preferences.removeObject(forKey: key)
        }
        LegacyProfileMigration.preferences.removeObject(forKey: "explorer-profile")
        UserDefaults.standard.removeObject(forKey: "explorer-age")
    }

    static func eraseFiles(_ file: URL) throws {
        for directory in [file.deletingLastPathComponent(), NarrationClient().directory, PreparedAssets().directory] {
            if FileManager.default.fileExists(atPath: directory.path) { try FileManager.default.removeItem(at: directory) }
            guard !FileManager.default.fileExists(atPath: directory.path) else { throw FamilyError.saveFailed }
        }
    }
}
