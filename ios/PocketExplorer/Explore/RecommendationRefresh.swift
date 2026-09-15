import BackgroundTasks
import Foundation

@MainActor
enum RecommendationRefresh {
    static let identifier = "com.haichang.pocketexplorer.discoveries"

    @discardableResult
    static func schedule(now: Date = Date(), submit: (BGAppRefreshTaskRequest) throws -> Void = { try BGTaskScheduler.shared.submit($0) }) -> Bool {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = now.addingTimeInterval(21600)
        do { try submit(request); return true }
        catch { return false }
    }

    static func run(store: RecommendationStore, base: URL, language: String, age: Int, cache: PreparedAssets = PreparedAssets()) async {
        await withTaskCancellationHandler {
            await store.synchronize(base: base, language: language, age: age)
            guard !Task.isCancelled else { return }
            await store.prefetch(base: base, cache: cache, context: DailySelection.context(language: language, age: age))
        } onCancel: {
            Task { @MainActor in store.cancelSynchronization(language: language, age: age) }
        }
    }
}
