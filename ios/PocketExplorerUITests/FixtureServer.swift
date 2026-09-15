import Foundation

enum FixtureServer {
    static var base: String {
        ProcessInfo.processInfo.environment["POCKET_AI_FIXTURE_URL"] ?? "http://127.0.0.1:4197"
    }
}
