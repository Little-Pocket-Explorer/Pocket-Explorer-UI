import XCTest
import CoreLocation

enum FixtureServer {
    static var base: String {
        ProcessInfo.processInfo.environment["POCKET_AI_FIXTURE_URL"] ?? "http://127.0.0.1:4197"
    }
}

enum PitchFixtureServer {
    static var base: String {
        ProcessInfo.processInfo.environment["POCKET_PITCH_FIXTURE_URL"] ?? "http://127.0.0.1:4236"
    }

    @MainActor static func setEventLocation() {
        XCUIDevice.shared.location = XCUILocation(location: CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: -33.871373, longitude: 151.212548),
            altitude: 0, horizontalAccuracy: 10, verticalAccuracy: 10, timestamp: Date()
        ))
    }
}

extension XCUIApplication {
    func allowLocationIfRequested() {
        let alert = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch
        if alert.waitForExistence(timeout: 5) {
            XCTAssertTrue(alert.label.localizedCaseInsensitiveContains("location"))
            let allow = alert.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "While Using")).firstMatch
            XCTAssertTrue(allow.exists, alert.debugDescription)
            allow.tap()
        }
    }

    func unlockSavedObservation(choice: Int = 0) {
        func tapVisible(_ identifier: String) {
            let matches = buttons.matching(identifier: identifier)
            let button = matches.allElementsBoundByIndex.last ?? matches.firstMatch
            XCTAssertTrue(button.waitForExistence(timeout: 10), identifier)
            for _ in 0..<12 where !button.isHittable { swipeUp() }
            XCTAssertTrue(button.isHittable, identifier); button.tap()
        }
        XCTAssertFalse(buttons["reveal-card"].exists)
        tapVisible("pending-quiz")
        tapVisible("quiz-choice-\(choice)")
        tapVisible("quiz-check")
        tapVisible("quiz-reveal")
        XCTAssertTrue(buttons["reveal-card"].waitForExistence(timeout: 10))
    }
    func openLatestSavedQuestion() {
        let conversation = buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "conversation-")).firstMatch
        XCTAssertTrue(conversation.waitForExistence(timeout: 5)); conversation.tap()
        let question = buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "history-question-")).firstMatch
        XCTAssertTrue(question.waitForExistence(timeout: 5)); question.tap()
    }
}
