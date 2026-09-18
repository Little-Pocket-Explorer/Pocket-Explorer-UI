# Video workflow alignment

Date: 2026-09-18

The supplied video is treated as the workflow reference. Native SwiftUI keeps its existing visual language while preserving every available real service boundary.

Existing behavior retained: prepared questions, conversation, card creation and detail, approved-friend gift/exchange, broad-area Map publication, revocable links, nearby Events, event sharing in Messages, Friend Profile, card requests and recall quizzes.

New behavior: the Map bell opens Notifications with real friend requests, card transfers, cached Events and due quizzes. Each row routes into the existing protected action or destination. Reminder settings remain available through Notifications.

The share UI exposes only implemented behavior. It does not claim a friends-with-location audience because no corresponding backend contract exists.

Windows validation: Swift diagnostics pass, all ten catalogs have 670 identical unique keys, and static route/diff checks pass. XCTest/XCUITest, screenshots and changed-Swift coverage remain pending on macOS.