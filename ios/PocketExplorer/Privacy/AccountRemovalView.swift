import SwiftUI

struct AccountRemovalView: View {
    let removal: AccountRemoval

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Image(systemName: removal.finished ? "checkmark.circle.fill" : "lock.shield.fill")
                    .font(.system(size: 64)).foregroundStyle(Theme.forest)
                Text(L10n.text(removal.finished ? "Account deleted" : "Deleting your account"))
                    .font(.system(.largeTitle, design: .rounded, weight: .bold)).multilineTextAlignment(.center)
                Text(L10n.text(removal.finished ? "Your account and shared links have been removed. Close and reopen Pocket Explorer to start a new journal." : "We are removing your profile, discoveries, conversations and shared links."))
                    .multilineTextAlignment(.center).foregroundStyle(Theme.muted)
                if removal.busy { ProgressView().accessibilityIdentifier("account-deletion-progress") }
                if let error = removal.error {
                    Text(error).multilineTextAlignment(.center).accessibilityIdentifier("account-deletion-error")
                    Button("Retry deletion") { Task { await removal.resume() } }
                        .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("account-deletion-retry")
                }
                Link("Contact support", destination: URL(string: "https://pocket.changhai.me/support")!)
            }.padding(30).frame(maxWidth: .infinity)
        }.background(Theme.paper).accessibilityIdentifier(removal.finished ? "account-deletion-complete" : "account-deletion-pending")
    }
}
