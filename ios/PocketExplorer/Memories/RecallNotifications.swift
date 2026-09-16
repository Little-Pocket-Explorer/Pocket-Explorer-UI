import Foundation
import Observation
import UserNotifications

struct RecallNotice: Equatable, Identifiable {
    static let prefix = "pocket-recall-"
    let discoveryID: UUID
    let date: Date
    let language: AppLanguage
    var id: String { Self.prefix + discoveryID.uuidString }

    static func plan(_ discoveries: [Discovery], now: Date = .now, calendar: Calendar = .current, language: AppLanguage = .current) -> [Self] {
        var earliest = now.addingTimeInterval(60)
        return discoveries.filter { $0.ai != nil && $0.collectible?.versions.contains(where: { $0.audience == "demo" }) != true }
            .sorted { ReminderPolicy.dueDate($0) == ReminderPolicy.dueDate($1) ? $0.id.uuidString < $1.id.uuidString : ReminderPolicy.dueDate($0) < ReminderPolicy.dueDate($1) }
            .prefix(3).compactMap { discovery in
                let after = max(earliest, ReminderPolicy.dueDate(discovery))
                guard let date = calendar.nextDate(after: after, matching: DateComponents(hour: 17, minute: 0), matchingPolicy: .nextTime),
                      date.timeIntervalSince(now) <= 8 * 86400 else { return nil }
                earliest = date.addingTimeInterval(1)
                return Self(discoveryID: discovery.id, date: date, language: language)
            }
    }
}

@MainActor protocol RecallNotificationClient {
    func allowed() async -> Bool
    func request() async throws -> Bool
    func pending() async -> [String]
    func remove(_ identifiers: [String])
    func add(_ notice: RecallNotice) async throws
}

@MainActor struct SystemRecallNotificationClient: RecallNotificationClient {
    let center = UNUserNotificationCenter.current()
    func allowed() async -> Bool { [.authorized, .provisional, .ephemeral].contains(await center.notificationSettings().authorizationStatus) }
    func request() async throws -> Bool { try await center.requestAuthorization(options: [.alert, .sound]) }
    func pending() async -> [String] { await center.pendingNotificationRequests().map(\.identifier) }
    func remove(_ identifiers: [String]) { center.removePendingNotificationRequests(withIdentifiers: identifiers) }
    func add(_ notice: RecallNotice) async throws {
        let content = UNMutableNotificationContent()
        content.title = L10n.text("A little look back", language: notice.language)
        content.body = L10n.text("A discovery has a little question for you. Ready to look back?", language: notice.language)
        content.userInfo = ["discoveryID": notice.discoveryID.uuidString]
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notice.date)
        try await center.add(UNNotificationRequest(identifier: notice.id, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)))
    }
}

@MainActor @Observable final class RecallNotifications: NSObject, UNUserNotificationCenterDelegate {
    static let shared = RecallNotifications(client: SystemRecallNotificationClient(), preferences: ShareStorageScope.preferences)
    private let client: any RecallNotificationClient
    private let preferences: UserDefaults
    private var desired: [RecallNotice] = []
    private var updating = false
    private var revision = 0
    private var permissionRevision = 0
    private(set) var requesting = false
    private(set) var enabled: Bool
    private(set) var allowed = false
    private(set) var error: String?
    var opening: UUID?

    init(client: any RecallNotificationClient, preferences: UserDefaults) {
        self.client = client; self.preferences = preferences
        enabled = preferences.bool(forKey: "recall-notifications")
        super.init()
    }
    func install() { UNUserNotificationCenter.current().delegate = self }

    @discardableResult func open(_ url: URL) -> Bool {
        let parts = url.pathComponents.filter { $0 != "/" }
        guard url.scheme == "pocketexplorer", url.host == "recall", url.user == nil, url.password == nil, url.port == nil,
              url.query == nil, url.fragment == nil, parts.count == 1, let id = UUID(uuidString: parts[0]) else { return false }
        opening = id
        return true
    }

    func setEnabled(_ value: Bool) async {
        guard !value || !requesting else { return }
        permissionRevision += 1
        let current = permissionRevision
        error = nil
        requesting = value
        do {
            let granted = value ? try await client.request() : false
            guard current == permissionRevision else { return }
            requesting = false
            enabled = granted
            preferences.set(enabled, forKey: "recall-notifications")
            await synchronize(desired)
        } catch {
            guard current == permissionRevision else { return }
            requesting = false
            self.error = error.localizedDescription
        }
    }

    func synchronize(_ notices: [RecallNotice]) async {
        desired = notices; revision += 1
        guard !updating else { return }
        updating = true
        defer { updating = false }
        repeat {
            let current = revision
            allowed = await client.allowed()
            let owned = await client.pending().filter { $0.hasPrefix(RecallNotice.prefix) }
            client.remove(owned)
            if enabled && allowed {
                do { for notice in desired { try await client.add(notice) }; error = nil }
                catch { self.error = error.localizedDescription }
            }
            if current == revision { return }
        } while true
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let text = response.notification.request.content.userInfo["discoveryID"] as? String
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier, let text, let id = UUID(uuidString: text) {
            Task { @MainActor in self.opening = id }
        }
        completionHandler()
    }
}
