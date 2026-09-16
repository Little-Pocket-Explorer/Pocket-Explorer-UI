import SwiftUI

struct AIDataPermissionView: View {
    let family: FamilyStore
    @State private var permission = AIDataPermission()

    var body: some View {
        Section("Cloud AI permission") {
            Label(L10n.text(permission.allowed ? "Cloud AI is allowed" : "Cloud AI is off"), systemImage: permission.allowed ? "checkmark.shield.fill" : "shield.lefthalf.filled")
                .foregroundStyle(Theme.forest).accessibilityIdentifier("ai-permission-status")
            Text("With your permission, questions, selected photos, age, interests and relevant earlier discoveries are sent through our Cloudflare backend to cloud AI services. Answer text is also used to create narration and card illustrations.")
                .font(.subheadline).accessibilityIdentifier("ai-permission-disclosure")
            Text("Review the service providers and data handling in our privacy policy before allowing cloud AI. Do not include names, addresses, school details or photos of people.")
                .font(.subheadline)
            Text("You can keep using saved cards and prepared discoveries without allowing cloud AI. Turning it off stops new requests. Requests already sent cannot be recalled. Use Delete account and data to remove saved server records.")
                .font(.subheadline).foregroundStyle(Theme.muted)
            if family.family != nil && family.parentUnlocked {
                Link("Privacy policy", destination: URL(string: "https://pocket.changhai.me/privacy")!)
                if !permission.allowed && !permission.pendingWithdrawal {
                    Button("Allow cloud AI data use") {
                        guard let parent = try? family.deletionToken(), let connection = try? ConnectionVault().loadOrCreate() else { return }
                        Task { await permission.allow(parent: parent, connection: connection) }
                    }.accessibilityIdentifier("allow-ai-data")
                }
            } else if family.family == nil {
                Text("Create family settings above before a grown-up can allow cloud AI.").font(.subheadline)
            }
            if permission.allowed {
                Button("Turn off cloud AI", role: .destructive) {
                    guard let connection = try? ConnectionVault().loadOrCreate() else { return }
                    Task { await permission.withdraw(connection: connection) }
                }.accessibilityIdentifier("withdraw-ai-data")
            }
            if permission.pendingWithdrawal {
                Text("Cloud AI is off on this device. We will finish the withdrawal on the server when you are online.")
                    .font(.subheadline).accessibilityIdentifier("ai-withdrawal-pending")
            }
            if let error = permission.error {
                Text(error).font(.subheadline).accessibilityIdentifier("ai-permission-error")
                Button("Try again") { synchronize() }.accessibilityIdentifier("retry-ai-permission")
            }
            if permission.busy { ProgressView("Saving…") }
        }.disabled(permission.busy).id("ai-permission-section")
            .task { synchronize() }
    }

    private func synchronize() {
        guard let connection = try? ConnectionVault().loadOrCreate() else { return }
        Task { await permission.synchronize(connection: connection) }
    }
}
