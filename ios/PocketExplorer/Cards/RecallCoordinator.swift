import Foundation
import Observation

@MainActor @Observable
final class RecallCoordinator {
    private(set) var busy = false
    private(set) var error: String?
    @ObservationIgnored private var pending: Task<Void, Never>?
    var client = CollectibleClient()
    var registration = PreparedRegistration.shared

    func synchronize(store: TripStore, connection: ShareConnection) async {
        if let pending { await pending.value; return }
        guard store.family.allows(.exploration) else { return }
        let task = Task { @MainActor in
            busy = true
            defer { busy = false; pending = nil }
            for _ in 0..<30 {
                guard !Task.isCancelled, store.family.allows(.exploration),
                      let attempt = store.state.recallAttempts?.first(where: { $0.failure == nil }) else { return }
                do {
                    try await registration.register(attempt.explorationID, store: store, connection: connection)
                    let receipt = try await client.recall(attempt, connection: connection)
                    try store.applyRecall(receipt, attemptID: attempt.id)
                    error = nil
                } catch let failure as CollectibleError where [.newDiscovery, .versionLimit, .requestConflict].contains(failure) {
                    do { try store.failRecall(attempt.id, code: failure.rawValue) }
                    catch { self.error = error.localizedDescription; return }
                    error = failure.localizedDescription
                } catch {
                    if !Task.isCancelled { self.error = error.localizedDescription }
                    return
                }
            }
        }
        pending = task
        await task.value
    }
}
