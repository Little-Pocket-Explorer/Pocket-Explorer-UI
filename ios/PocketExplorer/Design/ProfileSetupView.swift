import SwiftUI

struct ProfileSetupView: View {
    var onComplete: (ExplorerProfile) -> Void
    @State private var email = ""
    @State private var error: String?
    @State private var emailOpen = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    Image("duck").resizable().scaledToFill().frame(height: 330).clipped()
                    LinearGradient(colors: [.clear, Theme.paper], startPoint: .top, endPoint: .bottom).frame(height: 130)
                }
                VStack(spacing: 14) {
                    Eyebrow(text: "Pocket Explorer")
                    Text(L10n.text("A bigger world is waiting.")).font(.system(.largeTitle, design: .rounded, weight: .heavy)).multilineTextAlignment(.center)
                    Text(L10n.text("Set up by a parent. Made for curious kids.")).font(.subheadline).foregroundStyle(Theme.muted)
                    if !emailOpen {
                        VStack(spacing: 12) {
                            provider("Continue with Apple", icon: "apple.logo")
                            provider("Continue with Google", icon: "g.circle")
                            Button { emailOpen = true } label: { providerContent("Continue with Email", icon: "envelope") }
                                .buttonStyle(ProfileProviderStyle()).accessibilityIdentifier("signup-email-option")
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(L10n.text("Email address")).font(.caption.bold()).foregroundStyle(Theme.muted)
                            TextField("parent@example.com", text: $email).textInputAutocapitalization(.never).keyboardType(.emailAddress)
                                .textContentType(.emailAddress).padding(15).background(.white, in: RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.line)).accessibilityIdentifier("signup-email")
                        }
                        if let error { Text(error).font(.caption).foregroundStyle(.red).accessibilityIdentifier("signup-error") }
                        Button(action: continueWithEmail) { Label(L10n.text("Continue with Email"), systemImage: "envelope") }
                            .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("signup-continue")
                        Button("Back to sign-up options") { emailOpen = false; error = nil }.font(.caption).foregroundStyle(Theme.forest)
                    }.padding(.top, 14)
                    Text("For this prototype, your email stays on this iPhone.").font(.caption2).foregroundStyle(Theme.muted).multilineTextAlignment(.center)
                }.padding(26).padding(.top, -15)
            }
        }
        .background(Theme.paper).foregroundStyle(Theme.ink)
    }

    private func continueWithEmail() {
        do { onComplete(try ProfileSettings.save(email: email)) }
        catch { self.error = error.localizedDescription }
    }

    private func provider(_ title: String, icon: String) -> some View {
        Button { } label: { providerContent(title, icon: icon) }.buttonStyle(ProfileProviderStyle()).disabled(true)
    }

    private func providerContent(_ title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon).frame(width: 28)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right").font(.caption.bold())
        }
    }
}

private struct ProfileProviderStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.subheadline, design: .rounded, weight: .bold)).frame(maxWidth: .infinity, minHeight: 50)
            .background(.white, in: RoundedRectangle(cornerRadius: 18)).foregroundStyle(Theme.muted)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.line))
    }
}