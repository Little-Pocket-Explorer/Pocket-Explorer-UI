import Foundation
import Observation
import SwiftUI

enum ExplorerTab: Int, CaseIterable { case chat, map, memories, friends }

struct ExplorationDestination: Hashable {
    var id = UUID()
    var tripID: UUID?
    var question = ""
    var recordID: UUID?
    var presentAnswer = false
    var entry: ExplorationEntry = .compose
    var parentID: UUID?
    var evolveFrom: String?
}

enum ExplorerRoute: Hashable {
    case explore(ExplorationDestination)
    case card(UUID), newCard(UUID), trip(UUID), memory(UUID), mapShare(UUID), recall(UUID)
    case share(UUID, UUID?)
    case collection, nearby, reminders, history, profile
    case event(String), eventShare(String), sharedDiscovery(String)
    case friendProfile(String), friend(String, Int), friendCard(String, String), exchange(String, String?)
}

@MainActor @Observable final class AppNavigation {
    var tab: ExplorerTab = .chat
    var paths: [ExplorerTab: [ExplorerRoute]] = [:]
    private(set) var roots: [ExplorerTab: Int] = [:]

    var current: ExplorerRoute? { paths[tab]?.last }

    func open(_ route: ExplorerRoute, in destination: ExplorerTab? = nil) {
        let target = destination ?? tab
        var path = paths[target] ?? []
        if let index = path.firstIndex(of: route) { path = Array(path.prefix(index + 1)) }
        else { path.append(route) }
        paths[target] = path
        tab = target
    }

    func home() {
        paths[.chat] = []
        roots[.chat, default: 0] += 1
        tab = .chat
    }

    func back() {
        guard paths[tab]?.isEmpty == false else { return }
        paths[tab]?.removeLast()
    }
}

private struct ExplorerNavigationKey: EnvironmentKey {
    static let defaultValue: AppNavigation? = nil
}

extension EnvironmentValues {
    var explorerNavigation: AppNavigation? {
        get { self[ExplorerNavigationKey.self] }
        set { self[ExplorerNavigationKey.self] = newValue }
    }
}

struct FeatureNavigation<Content: View>: View {
    @Environment(\.explorerNavigation) private var navigation
    @ViewBuilder var content: Content
    var body: some View {
        if navigation != nil { content }
        else { NavigationStack { content } }
    }
}
