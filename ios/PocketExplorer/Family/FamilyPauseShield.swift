import SwiftUI

struct FamilyPauseShield: UIViewRepresentable {
    let family: FamilyStore
    @Environment(AccountRemoval.self) private var removal
    @Environment(\.locale) private var locale
    @Environment(\.layoutDirection) private var direction
    @Environment(\.dynamicTypeSize) private var typeSize

    func makeUIView(context: Context) -> Surface { Surface() }
    func updateUIView(_ view: Surface, context: Context) {
        view.update(blocked: family.timeFinished || family.storageFailed, content: AnyView(
            FamilyPauseView(family: family)
                .environment(removal)
                .environment(\.locale, locale)
                .environment(\.layoutDirection, direction)
                .environment(\.dynamicTypeSize, typeSize)
                .preferredColorScheme(.light)
        ))
    }
    static func dismantleUIView(_ view: Surface, coordinator: ()) { view.close() }

    final class Surface: UIView {
        private var blocked = false
        private var content = AnyView(EmptyView())
        private var shield: UIWindow?
        private weak var previousKeyWindow: UIWindow?

        func update(blocked: Bool, content: AnyView) {
            self.blocked = blocked; self.content = content; refresh()
        }
        override func didMoveToWindow() { super.didMoveToWindow(); refresh() }
        private func refresh() {
            guard blocked, let window, let scene = window.windowScene else { close(); return }
            if let controller = shield?.rootViewController as? UIHostingController<AnyView> {
                controller.rootView = content
                return
            }
            // A SwiftUI overlay sits beneath presented sheets. The pause must cover those sheets too.
            previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
            let shield = UIWindow(windowScene: scene)
            shield.windowLevel = UIWindow.Level(rawValue: window.windowLevel.rawValue + 1)
            let controller = UIHostingController(rootView: content)
            controller.view.accessibilityViewIsModal = true
            shield.rootViewController = controller
            self.shield = shield
            shield.makeKeyAndVisible()
        }
        func close() {
            guard let shield else { return }
            let restoreFocus = shield.isKeyWindow
            shield.isHidden = true; shield.rootViewController = nil; self.shield = nil
            if restoreFocus { previousKeyWindow?.makeKey() }
            previousKeyWindow = nil
        }
    }
}
