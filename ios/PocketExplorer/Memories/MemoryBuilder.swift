import Foundation

enum MemoryBuilder {
    static func build(tripID: UUID, discoveries: [Discovery]) -> TripMemory {
        TripMemory(id: tripID, chapters: discoveries.flatMap { discovery in
            [
                MemoryChapter(id: "\(discovery.id)-question", title: "It started with a why.", text: discovery.question, subject: discovery.subject, language: discovery.language),
                MemoryChapter(id: "\(discovery.id)-observation", title: "Then I looked closer.", text: discovery.observation, subject: discovery.subject, language: discovery.language),
                MemoryChapter(id: "\(discovery.id)-discovery", title: "A little discovery, kept.", text: discovery.explanation, subject: discovery.subject, language: discovery.language)
            ]
        })
    }
}

enum ReminderPolicy {
    static let interval: TimeInterval = 7 * 86_400

    static func isEligible(_ discovery: Discovery, now: Date) -> Bool {
        discovery.ai != nil && now >= dueDate(discovery)
    }

    static func dueDate(_ discovery: Discovery) -> Date {
        if let reviewed = discovery.recallReviewedAt ?? discovery.quizAnsweredAt { return reviewed.addingTimeInterval(interval) }
        return discovery.createdAt.addingTimeInterval(86400)
    }

    static func practiceCandidate(_ discoveries: [Discovery], now: Date) -> Discovery? {
        guard !discoveries.contains(where: { isEligible($0, now: now) }) else { return nil }
        return discoveries.filter { $0.ai?.quiz.isValid == true && $0.isVerified && $0.recallReviewedAt == nil }
            .sorted { $0.createdAt > $1.createdAt }.first
    }

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
