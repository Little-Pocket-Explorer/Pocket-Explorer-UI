import SwiftUI

struct FamilySettingsView: View {
    let family: FamilyStore
    @Environment(\.dismiss) private var dismiss
    @State private var profile = ExplorerProfile()
    @State private var policy = FamilyPolicy()
    @State private var pin = ""
    @State private var confirmPIN = ""
    @State private var recovery = ""
    @State private var recovering = false
    @State private var working = false
    @State private var error: String?
    @State private var saved = false

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 5)) { _ in
                Form {
                    Section {
                        HStack(spacing: 16) {
                            Image(systemName: "leaf.circle.fill").font(.system(size: 52)).foregroundStyle(Theme.forest)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Room to explore").font(.system(.title2, design: .rounded, weight: .bold))
                                Text("A grown-up sets the boundaries. Curiosity leads the way.").font(.subheadline).foregroundStyle(Theme.muted)
                            }
                        }.padding(.vertical, 8).listRowBackground(Color.clear)
                    }
                    if let code = family.recoveryCode {
                        Section("Keep your recovery code") {
                            Text("Save this somewhere only grown-ups can access. It can reset your PIN.").font(.subheadline)
                            Text(code).font(.system(.footnote, design: .monospaced)).textSelection(.enabled).accessibilityIdentifier("family-recovery-code")
                            Button("I saved the recovery code") { family.clearRecoveryCode() }.accessibilityIdentifier("family-recovery-saved")
                        }
                    } else if family.family == nil || family.parentUnlocked {
                        profileFields
                        if family.family == nil {
                            Section("Choose a parent PIN") {
                                pinFields
                                Text("Use six digits that your child does not know.").font(.caption).foregroundStyle(Theme.muted)
                                Button("Create family settings") { run { connection in
                                    guard pin == confirmPIN else { throw FamilyError.invalidProfile }
                                    try await family.setup(profile: profile, pin: pin, connection: connection)
                                    pin = ""; confirmPIN = ""
                                } }.accessibilityIdentifier("family-create")
                            }
                        } else {
                            policyFields
                            Section {
                                Button("Save family settings") { run { connection in
                                    try await family.save(profile: profile, policy: policy, connection: connection)
                                    UserDefaults.standard.set(profile.age, forKey: "explorer-age")
                                    saved = true
                                } }.accessibilityIdentifier("family-save")
                                if saved { Label("Family settings saved", systemImage: "checkmark.circle.fill").foregroundStyle(Theme.forest).accessibilityIdentifier("family-saved") }
                            }
                        }
                    } else {
                        Section(L10n.text(recovering ? "Reset parent PIN" : "For grown-ups")) {
                            if recovering {
                                TextField("Recovery code", text: $recovery).textInputAutocapitalization(.never).autocorrectionDisabled().accessibilityIdentifier("family-recovery-input")
                                pinFields
                            } else {
                                SecureField("Six-digit parent PIN", text: $pin).keyboardType(.numberPad).accessibilityIdentifier("family-pin")
                            }
                            Button(L10n.text(recovering ? "Reset PIN" : "Unlock family settings")) { run { connection in
                                if recovering {
                                    guard pin == confirmPIN else { throw FamilyError.invalidProfile }
                                    try await family.recover(code: recovery.trimmingCharacters(in: .whitespacesAndNewlines), pin: pin, connection: connection)
                                } else { try await family.unlock(pin: pin, connection: connection) }
                                pin = ""; confirmPIN = ""; recovery = ""; recovering = false
                                loadProfile()
                            } }.accessibilityIdentifier("family-unlock")
                            Button(L10n.text(recovering ? "Use parent PIN" : "Forgot your PIN?")) { recovering.toggle(); pin = ""; error = nil }
                        }
                    }
                    if working { ProgressView("Saving…") }
                    if let error { Section { Text(error).foregroundStyle(Theme.ink).accessibilityIdentifier("family-error") } }
                }.disabled(working).scrollContentBackground(.hidden).background(ExplorerBackdrop())
            }
            .navigationTitle("Family settings").navigationBarTitleDisplayMode(.inline)
            .toolbar { Button("Done") { dismiss() }.accessibilityIdentifier("family-done") }
        }.tint(Theme.forest)
            .onAppear { loadProfile(); try? family.endActive() }
            .onDisappear { family.beginActive(); Task { await family.lock(connection: try? ConnectionVault().loadOrCreate()) } }
    }

    private var profileFields: some View {
        Section("Explorer profile") {
            HStack { Spacer(); ExplorerAvatar(size: 84, avatar: profile.avatar); Spacer() }.listRowBackground(Color.clear)
            TextField("Nickname", text: $profile.nickname).accessibilityIdentifier("family-nickname")
            Stepper("Age: \(profile.age)", value: $profile.age, in: 5...18)
            Picker("Explorer avatar", selection: $profile.avatar) {
                Text("Mimi").tag("mimi"); Text("Dou Dou").tag("dou-dou"); Text("AJ").tag("aj")
            }
            Picker("Explanation style", selection: $profile.learningLevel) {
                Text("Simple discoveries").tag(1); Text("A little more detail").tag(2); Text("Deeper connections").tag(3)
            }
            ForEach(ExplorerProfile.interestChoices, id: \.self) { interest in
                Toggle(L10n.text(interest.capitalized), isOn: Binding(get: { profile.interests.contains(interest) }, set: { value in
                    profile.interests.removeAll { $0 == interest }; if value { profile.interests.append(interest) }
                }))
            }
        }
    }
    private var pinFields: some View {
        Group {
            SecureField("Six-digit parent PIN", text: $pin).keyboardType(.numberPad).accessibilityIdentifier("family-pin")
            SecureField("Confirm parent PIN", text: $confirmPIN).keyboardType(.numberPad).accessibilityIdentifier("family-confirm-pin")
        }
    }
    private var policyFields: some View {
        Group {
            Section("Family permissions") {
                Toggle("AI exploration", isOn: $policy.exploration).accessibilityIdentifier("family-exploration")
                Toggle("Nearby events", isOn: $policy.events)
                Toggle("Share links", isOn: $policy.sharing).accessibilityIdentifier("family-sharing")
                Toggle("Friends and text chat", isOn: $policy.social).accessibilityIdentifier("family-social")
                Toggle("Publish discoveries on the map", isOn: $policy.mapSharing).disabled(!policy.sharing).accessibilityIdentifier("family-mapSharing")
                Toggle("Include a nickname in links", isOn: $policy.nameSharing).disabled(!policy.sharing)
                Toggle("Include a city in links", isOn: $policy.citySharing).disabled(!policy.sharing)
                Text("Private photos and exact personal locations stay private.").font(.caption).foregroundStyle(Theme.muted)
            }
            Section("Screen time") {
                Stepper("Daily minutes: \(policy.dailyMinutes)", value: $policy.dailyMinutes, in: 0...240, step: 5).accessibilityIdentifier("family-minutes")
                Text("Zero means no daily limit. Time is counted while the app is active.").font(.caption).foregroundStyle(Theme.muted)
                Text("Used today: \(family.usedSeconds / 60) minutes").font(.subheadline)
            }
        }
    }
    private func loadProfile() {
        if let existing = family.family { profile = existing.profile; policy = existing.policy }
        else {
            if let existing = LegacyProfileMigration.draft() {
                profile = existing
                let age = UserDefaults.standard.integer(forKey: "explorer-age")
                if (5...18).contains(age) { profile.age = age }
            }
            else {
                profile.language = AppLanguage.current.rawValue
                let age = UserDefaults.standard.integer(forKey: "explorer-age")
                profile.age = (5...18).contains(age) ? age : 7
            }
        }
    }
    private func run(_ operation: @escaping (ShareConnection) async throws -> Void) {
        working = true; error = nil; saved = false
        Task {
            defer { working = false }
            do { try await operation(ConnectionVault().loadOrCreate()) }
            catch { self.error = error.localizedDescription }
        }
    }
}

struct FamilyPauseView: View {
    let family: FamilyStore
    @State private var settings = false
    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "moon.stars.fill").font(.system(size: 64)).foregroundStyle(Theme.forest)
            Text("A little pause").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text(family.storageFailed ? FamilyError.saveFailed.localizedDescription : FamilyError.timeFinished.localizedDescription)
                .multilineTextAlignment(.center).foregroundStyle(Theme.muted)
            Button("Family settings") { settings = true }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("pause-family-settings")
        }.padding(30).frame(maxWidth: .infinity, maxHeight: .infinity).background(Theme.paper)
            .sheet(isPresented: $settings) { FamilySettingsView(family: family) }
    }
}
