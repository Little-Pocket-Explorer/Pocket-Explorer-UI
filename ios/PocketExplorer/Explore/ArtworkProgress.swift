import Foundation

enum ArtworkProgress: Equatable {
    case ready, waiting, drawing, slow, paused, failed, exhausted, unavailable

    static func resolve(_ discovery: Discovery, error: String? = nil, stopped: Bool = false, now: Date = Date()) -> ArtworkProgress {
        if discovery.artworkFilename != nil || discovery.ai == nil { return .ready }
        if stopped { return .unavailable }
        if let job = discovery.artwork, job.status == "failed" { return job.allowsRetry ? .failed : .exhausted }
        if error != nil { return .paused }
        if let expiry = discovery.artwork?.expiresAt, now.timeIntervalSince1970 * 1000 >= expiry { return .paused }
        let started = discovery.artwork?.updatedAt.map { Date(timeIntervalSince1970: $0 / 1000) } ?? discovery.createdAt
        if now.timeIntervalSince(started) >= 30 { return .slow }
        return discovery.artwork?.status == "working" ? .drawing : .waiting
    }

    var title: String {
        switch self {
        case .ready: return "Your card is ready"
        case .waiting: return "Your card is saved"
        case .drawing: return "Adding a little colour"
        case .slow: return "A little more time for the picture"
        case .paused: return "Your discovery is safe"
        case .failed: return "The picture couldn't finish"
        case .exhausted, .unavailable: return "Keep exploring with this card"
        }
    }

    var message: String {
        switch self {
        case .ready: return "Your illustration is ready to explore."
        case .waiting, .drawing: return "The picture will appear here when it's ready. You can keep exploring."
        case .slow: return "This picture is taking longer. You can leave this screen and come back later."
        case .paused: return "We couldn't check your illustration. Your card is safe. We'll check again when you're connected."
        case .failed: return "Your words and discovery are saved. You can try the picture once more."
        case .exhausted, .unavailable: return "Your discovery is still yours. You can read it, make a memory and share your words."
        }
    }

    var symbol: String {
        switch self {
        case .ready: return "checkmark.circle.fill"
        case .waiting, .drawing: return "paintbrush.pointed.fill"
        case .slow: return "clock"
        case .paused: return "wifi.exclamationmark"
        case .failed, .exhausted, .unavailable: return "leaf.fill"
        }
    }

    var action: String? {
        switch self {
        case .failed: return "Try illustration again"
        case .paused, .slow: return "Check illustration"
        default: return nil
        }
    }
}
