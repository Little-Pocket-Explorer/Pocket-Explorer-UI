import CryptoKit
import Foundation

struct DailySnapshot: Codable, Equatable {
    var context: String
    var dateKey: String
    var createdAt: Date
    var rolloverAt: Date
    var timeZone: String
    var items: [PreparedContent]
    var removedCount: Int = 0
}

enum DailySelection {
    static func context(language: String, age: Int) -> String { "\(language):\(age)" }

    static func make(candidates: [PreparedContent], previous: DailySnapshot?, history: [String: Date],
                     language: String, age: Int, now: Date, timeZone: TimeZone, seed: String,
                     withdrawals: Set<PreparedReference> = []) -> DailySnapshot {
        let key = context(language: language, age: age)
        if var previous, previous.context == key, now < previous.rolloverAt {
            let oldCount = previous.items.count
            previous.items.removeAll { withdrawals.contains($0.reference) || $0.expiry <= now }
            previous.removedCount += oldCount - previous.items.count
            return previous
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let rollover = calendar.dateInterval(of: .day, for: now)?.end ?? now.addingTimeInterval(86400)
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        let dateKey = "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
        var seen = Set<String>()
        var remaining = candidates.filter {
            $0.isEligible(language: language, age: age, at: rollover) && !withdrawals.contains($0.reference) && seen.insert($0.topicID).inserted
        }
        let cutoff = now.addingTimeInterval(-7 * 86400)
        let tie: (PreparedContent) -> String = { item in
            SHA256.hash(data: Data("\(seed):\(dateKey):\(key):\(item.topicID)".utf8)).map { String(format: "%02x", $0) }.joined()
        }
        var selected: [PreparedContent] = []
        while selected.count < 3 && !remaining.isEmpty {
            remaining.sort { left, right in
                let leftDate = history[left.topicID] ?? .distantPast
                let rightDate = history[right.topicID] ?? .distantPast
                if (leftDate > cutoff) != (rightDate > cutoff) { return leftDate <= cutoff }
                if (history[left.topicID] == nil) != (history[right.topicID] == nil) { return history[left.topicID] == nil }
                let leftCategory = selected.filter { $0.reply.category == left.reply.category }.count
                let rightCategory = selected.filter { $0.reply.category == right.reply.category }.count
                if leftCategory != rightCategory { return leftCategory < rightCategory }
                if leftDate != rightDate { return leftDate < rightDate }
                return tie(left) < tie(right)
            }
            selected.append(remaining.removeFirst())
        }
        return DailySnapshot(context: key, dateKey: dateKey, createdAt: now, rolloverAt: rollover, timeZone: timeZone.identifier, items: selected)
    }
}
