import Foundation

enum MemoryBuilder {
    static func build(tripID: UUID, discoveries: [Discovery]) -> TripMemory {
        TripMemory(id: tripID, chapters: discoveries.flatMap { discovery in
            [
                MemoryChapter(id: "\(discovery.id)-question", title: "It started with a why.", text: discovery.question, subject: discovery.subject),
                MemoryChapter(id: "\(discovery.id)-observation", title: "Then I looked closer.", text: discovery.observation, subject: discovery.subject),
                MemoryChapter(id: "\(discovery.id)-discovery", title: "A little discovery, kept.", text: discovery.explanation, subject: discovery.subject)
            ]
        })
    }
}

enum ReminderPolicy {
    static let interval: TimeInterval = 7 * 86_400

    static func isEligible(_ trip: Trip, now: Date) -> Bool {
        guard let completed = trip.completedAt, trip.memory != nil else { return false }
        guard now >= completed.addingTimeInterval(interval) else { return false }
        if let dismissedUntil = trip.dismissedUntil, now < dismissedUntil { return false }
        return true
    }
}

struct MemoryPlayback: Equatable {
    private(set) var index = 0
    private(set) var isPlaying = false
    var count: Int

    mutating func play() {
        guard count > 0 else { return }
        if index >= count - 1 { index = 0 }
        isPlaying = true
    }
    mutating func pause() { isPlaying = false }
    mutating func replay() { index = 0; isPlaying = count > 0 }
    mutating func select(_ next: Int) {
        guard (0..<count).contains(next) else { return }
        index = next
        isPlaying = false
    }
    mutating func tick() {
        guard isPlaying else { return }
        if index < count - 1 { index += 1 }
        if index >= count - 1 { isPlaying = false }
    }
}
