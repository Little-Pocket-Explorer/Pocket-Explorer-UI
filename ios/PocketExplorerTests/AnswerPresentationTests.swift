import XCTest
@testable import PocketExplorer

@MainActor
final class AnswerPresentationTests: XCTestCase {
    func testRevealsGraphemesWithoutChangingTheAnswerInAllScripts() async {
        for text in ["A rainbow has many colours.", "彩虹为什么有七种颜色？", "لماذا تبدو السماء زرقاء؟", "e\u{301} 👩🏽‍🚀 👨‍👩‍👧‍👦", "こんにちは、世界！", "안녕 세상!"] {
            let model = AnswerPresentation()
            model.begin(text, animated: true)
            XCTAssertTrue(model.isRevealing)
            XCTAssertEqual(model.visibleText.count, 1)
            var lastCount = 0
            await model.reveal { delay in
                XCTAssertEqual(delay, .milliseconds(45))
                XCTAssertTrue(text.hasPrefix(model.visibleText))
                XCTAssertEqual(model.visibleText + model.hiddenText, text)
                XCTAssertGreaterThanOrEqual(model.visibleText.count, lastCount)
                lastCount = model.visibleText.count
            }
            XCTAssertEqual(model.text, text)
            XCTAssertEqual(model.visibleText, text)
            XCTAssertEqual(model.hiddenText, "")
            XCTAssertFalse(model.isRevealing)
        }
    }

    func testImmediateReadingAndBoundedLongAnswers() async {
        let model = AnswerPresentation()
        for text in ["", "好", "Read this without animation."] {
            model.begin(text, animated: false)
            await model.reveal { _ in XCTFail("Immediate reading must not schedule delays") }
            XCTAssertEqual(model.visibleText, text)
            XCTAssertFalse(model.isRevealing)
        }
        model.begin("好", animated: true)
        XCTAssertFalse(model.isRevealing)
        model.begin(String(repeating: "A", count: 1600), animated: true)
        var steps = 0
        await model.reveal { _ in steps += 1 }
        XCTAssertEqual(steps, 160)
        XCTAssertEqual(model.visibleText.count, 1600)
    }

    func testSkipAndCancellationCannotRestartOrOverwriteAnotherAnswer() async {
        let model = AnswerPresentation()
        model.begin("The old answer", animated: true)
        await model.reveal { _ in model.finish() }
        XCTAssertFalse(model.isRevealing)
        XCTAssertEqual(model.visibleText, "The old answer")
        model.begin("Another old answer", animated: true)
        await model.reveal { _ in model.begin("New answer", animated: false) }
        XCTAssertEqual(model.visibleText, "New answer")
        model.begin("Interrupted answer", animated: true)
        await model.reveal { _ in throw CancellationError() }
        XCTAssertEqual(model.visibleText, "Interrupted answer")
        XCTAssertFalse(model.isRevealing)
        model.begin("Cancelled task", animated: true)
        let task = Task { await model.reveal() }
        task.cancel()
        await task.value
        XCTAssertFalse(model.isRevealing)
    }

    func testAReplacedViewTaskCannotCompleteTheNewPresentation() async {
        let model = AnswerPresentation()
        let initialGeneration = model.generation
        model.begin("A newly opened cached answer", animated: true)
        await model.reveal(generation: initialGeneration) { _ in XCTFail("A stale view task must not start") }
        XCTAssertTrue(model.isRevealing)
        XCTAssertEqual(model.visibleText, "A")
        await model.reveal(generation: model.generation) { _ in }
        XCTAssertEqual(model.visibleText, model.text)
        XCTAssertFalse(model.isRevealing)
    }
}
