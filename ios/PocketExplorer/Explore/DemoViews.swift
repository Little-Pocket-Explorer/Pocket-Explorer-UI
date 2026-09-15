import SwiftUI

struct DemoActivationView: View {
    let activation: DemoActivation
    let demo: DemoStore
    @Environment(\.dismiss) private var dismiss
    @State private var busy = false
    @State private var activated = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                LeafBadge(symbol: "sparkles").frame(width: 76, height: 76)
                Text(L10n.text(activated ? "Demo access is ready" : "Activate demo access?"))
                    .font(.system(.title, design: .rounded, weight: .bold)).multilineTextAlignment(.center)
                Text(L10n.text(activated ? "Turn on Demo mode in My profile when you are ready to present." : "This private invitation enables demo controls only on this iPhone."))
                    .foregroundStyle(Theme.muted).multilineTextAlignment(.center)
                if let error { Text(error).foregroundStyle(.red).accessibilityIdentifier("demo-activation-error") }
                if activated {
                    Button("Done") { dismiss() }.buttonStyle(ExplorerButtonStyle())
                } else {
                    Button {
                        busy = true; error = nil
                        Task {
                            defer { busy = false }
                            do {
                                try await demo.activate(activation, connection: ConnectionVault().loadOrCreate())
                                activated = true
                            } catch { self.error = (error as? DemoError)?.localizedDescription ?? DemoError.unavailable.localizedDescription }
                        }
                    } label: {
                        if busy { ProgressView() } else { Text("Activate this iPhone") }
                    }.buttonStyle(ExplorerButtonStyle()).disabled(busy).accessibilityIdentifier("activate-demo")
                }
            }.padding(28).frame(maxWidth: .infinity, maxHeight: .infinity).background(Theme.paper)
                .toolbar { if !activated { Button("Cancel") { dismiss() }.disabled(busy) } }
        }.tint(Theme.forest).interactiveDismissDisabled(busy)
    }
}

struct DemoControls: View {
    let demo: DemoStore
    let language: String
    let age: Int

    var body: some View {
        if demo.authorized {
            Section {
                Toggle("Demo mode", isOn: Binding(get: { demo.enabled }, set: { enabled in
                    try? demo.setEnabled(enabled)
                    demo.selectContext(language: language, age: age)
                    if enabled && !demo.offlineReady { refresh() }
                })).accessibilityIdentifier("demo-mode-toggle").disabled(demo.busy)
                if demo.enabled {
                    Label(L10n.text(demo.offlineReady ? "Ready to present offline" : "Prepare content before presenting"), systemImage: demo.offlineReady ? "checkmark.circle.fill" : "arrow.down.circle")
                        .font(.subheadline).foregroundStyle(Theme.forest).accessibilityIdentifier("demo-readiness")
                    Button { refresh() } label: {
                        if demo.busy { ProgressView("Preparing your demo…") } else { Text("Refresh demo content") }
                    }.disabled(demo.busy).accessibilityIdentifier("refresh-demo")
                    if let error = demo.error { Text(error).font(.caption).foregroundStyle(.red) }
                }
                if let expiry = demo.expiresAt {
                    Text("Demo access ends: \(L10n.date(expiry, includeTime: true))").font(.caption).foregroundStyle(Theme.muted)
                }
            } header: { Text("Private demo") }
            footer: { Text("Prepared content stays in order until you refresh. Your daily discoveries are kept separately.") }
        }
    }

    private func refresh() {
        guard let connection = try? ConnectionVault().loadOrCreate() else { return }
        Task { await demo.refresh(connection: connection, language: language, age: age) }
    }
}
