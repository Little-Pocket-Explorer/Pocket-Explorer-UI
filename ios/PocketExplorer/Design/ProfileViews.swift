import SwiftUI

struct ExplorerProfileView: View {
    let store: TripStore
    @Binding var age: Int
    var onClose: () -> Void
    var onLanguage: () -> Void
    var onFamilySettings: () -> Void
    @Environment(\.explorerNavigation) private var navigation
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var account = false
    @State private var settingsPage: ProfileSettingsPage?

    private var profile: ExplorerProfile {
        if let profile = store.family.family?.profile { return profile }
        var draft = LegacyProfileMigration.draft() ?? ExplorerProfile()
        draft.age = age
        return draft
    }
    private var metrics: ExplorerProfileMetrics { ExplorerProfileMetrics(discoveries: store.state.discoveries, trips: store.state.trips) }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    ExplorerAvatar(size: 136, avatar: profile.avatar)
                    Text(profile.nickname).font(.system(.largeTitle, design: .rounded, weight: .heavy))
                        .multilineTextAlignment(.center).accessibilityIdentifier("profile-nickname-display")
                    Text("Age: \(profile.age)").font(.title3).foregroundStyle(Theme.muted)
                }.padding(.vertical, 8)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 12) { statistics }
                    VStack(spacing: 16) { statistics }
                }.padding(18).frame(maxWidth: .infinity).background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 24))
                if !profile.interests.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interests").font(.headline)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: dynamicTypeSize.isAccessibilitySize ? 220 : 130))], alignment: .leading, spacing: 10) {
                            ForEach(profile.interests, id: \.self) { interest in
                                Text(L10n.text(interest.capitalized)).font(.subheadline).padding(.horizontal, 14).padding(.vertical, 10)
                                    .frame(maxWidth: .infinity).background(Theme.mint, in: Capsule())
                            }
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                if store.family.family == nil {
                    Stepper("Age: \(age)", value: $age, in: 5...18).accessibilityIdentifier("profile-age")
                        .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 20))
                    Text("Your guide adjusts explanations to your age.").font(.caption).foregroundStyle(Theme.muted)
                }
                VStack(spacing: 0) {
                    Button { settingsPage = .child } label: { row("Child profile", icon: "person.fill") }
                        .accessibilityIdentifier("profile-child")
                    Divider().padding(.horizontal, 16)
                    Button { settingsPage = .preferences } label: { row("Discovery preferences", icon: "leaf.fill") }
                        .accessibilityIdentifier("profile-preferences")
                    Divider().padding(.horizontal, 16)
                    NavigationLink(value: ExplorerRoute.reminders) { row("Notifications", icon: "bell.fill") }
                        .accessibilityIdentifier("profile-reminders")
                    Divider().padding(.horizontal, 16)
                    Button { settingsPage = .privacy } label: { row("Privacy", icon: "checkmark.shield.fill") }
                        .accessibilityIdentifier("profile-privacy")
                    Divider().padding(.horizontal, 16)
                    Button { settingsPage = .cloudAI } label: { row("Cloud AI permission", icon: "brain.head.profile") }
                        .accessibilityIdentifier("profile-cloud-ai")
                    Divider().padding(.horizontal, 16)
                    Button { navigation?.tab = .social } label: { row("Friends & family", icon: "person.2.fill") }
                        .accessibilityIdentifier("profile-friends")
                    Divider().padding(.horizontal, 16)
                    Button { settingsPage = .location } label: { row("Location", icon: "mappin.circle.fill") }
                        .accessibilityIdentifier("profile-location")
                    Divider().padding(.horizontal, 16)
                    Button { settingsPage = .parentControls } label: { row("Parent controls", icon: "lock.fill") }
                        .accessibilityIdentifier("profile-parent-controls")
                    Divider().padding(.horizontal, 16)
                    Button(action: onFamilySettings) { row("Family settings", icon: "slider.horizontal.3") }
                        .accessibilityIdentifier("open-family-settings")
                    Divider().padding(.horizontal, 16)
                    Button { account = true } label: { row("Account", icon: "person.crop.circle") }
                        .accessibilityIdentifier("profile-account")
                }.buttonStyle(.plain).background(.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 24))
                if store.family.family != nil {
                    Text("Used today: \(store.family.usedSeconds / 60) minutes").font(.caption).foregroundStyle(Theme.ink)
                        .padding(.horizontal, 14).padding(.vertical, 10).background(.white.opacity(0.95), in: Capsule())
                }
                if store.demo.authorized {
                    VStack(alignment: .leading, spacing: 12) {
                        DemoControls(demo: store.demo, language: AppLanguage.current.rawValue, age: profile.age)
                    }.padding(16).frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 24))
                }
            }.padding(20)
        }.background(ProfileBackdrop()).foregroundStyle(Theme.ink)
            .navigationTitle("My profile").navigationBarTitleDisplayMode(.inline)
            .toolbar { Button("Done", action: onClose) }
            .sheet(isPresented: $account) { ProfileAccountSheet(profile: profile, onLanguage: onLanguage) }
            .navigationDestination(item: $settingsPage) { page in
                ProfileSettingsPageView(family: store.family, page: page, openFamilySettings: onFamilySettings)
            }
            .onAppear {
                if store.family.family == nil, UserDefaults.standard.object(forKey: "explorer-age") == nil,
                   let draft = LegacyProfileMigration.draft() { age = draft.age }
            }
    }

    private var statistics: some View {
        Group {
            stat(metrics.discoveries, label: "Discoveries", icon: "leaf.fill")
            stat(metrics.places, label: "Places", icon: "mappin.circle.fill")
            stat(metrics.rare, label: "Rare", icon: "star.fill")
        }
    }
    private func stat(_ value: Int, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Label(value.formatted(), systemImage: icon).font(.system(.title2, design: .rounded, weight: .heavy))
            Text(L10n.text(label)).font(.caption).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).accessibilityElement(children: .combine)
    }
    private func row(_ label: String, icon: String) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon).foregroundStyle(Theme.forest).frame(width: 32)
            Text(L10n.text(label)).multilineTextAlignment(.leading)
            Spacer(minLength: 4)
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.muted)
        }.padding(16).frame(maxWidth: .infinity, minHeight: 56, alignment: .leading).contentShape(Rectangle())
    }
}

private enum ProfileSettingsPage: Hashable {
    case child, preferences, privacy, cloudAI, location, parentControls

    var title: String {
        switch self {
        case .child: "Child profile"
        case .preferences: "Discovery preferences"
        case .privacy: "Privacy"
        case .cloudAI: "Cloud AI permission"
        case .location: "Location"
        case .parentControls: "Parent controls"
        }
    }
}

private struct ProfileSettingsPageView: View {
    let family: FamilyStore
    let page: ProfileSettingsPage
    var openFamilySettings: () -> Void
    @State private var profile = ExplorerProfile()
    @State private var policy = FamilyPolicy()
    @State private var pin = ""
    @State private var working = false
    @State private var saved = false
    @State private var error: String?

    var body: some View {
        Form {
            if family.family == nil {
                Section {
                    Text("A grown-up needs to create family settings before these choices can be changed.")
                        .foregroundStyle(Theme.muted)
                    Button("Create family settings", action: openFamilySettings)
                        .accessibilityIdentifier("profile-create-family")
                }
            } else if !family.parentUnlocked {
                Section("For grown-ups") {
                    SecureField("Six-digit parent PIN", text: $pin).keyboardType(.numberPad)
                        .accessibilityIdentifier("profile-settings-pin")
                    Button("Unlock family settings", action: unlock)
                        .disabled(pin.count != 6 || working).accessibilityIdentifier("profile-settings-unlock")
                }
            }

            fields.disabled(page != .cloudAI && !family.parentUnlocked)

            if family.parentUnlocked {
                Section {
                    Button("Save family settings", action: save).disabled(working)
                        .accessibilityIdentifier("profile-settings-save")
                    if saved { Label("Family settings saved", systemImage: "checkmark.circle.fill").foregroundStyle(Theme.forest) }
                }
            }
            if working { ProgressView("Saving…") }
            if let error { Section { Text(error).foregroundStyle(Theme.ink).accessibilityIdentifier("profile-settings-error") } }
        }
        .scrollContentBackground(.hidden).background(ProfileBackdrop())
        .navigationTitle(L10n.text(page.title)).navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: load)
        .onChange(of: family.family?.revision) { _, _ in load() }
        .onDisappear { Task { await family.lock(connection: try? ConnectionVault().loadOrCreate()) } }
    }

    @ViewBuilder private var fields: some View {
        switch page {
        case .child:
            Section("Explorer profile") {
                HStack { Spacer(); ExplorerAvatar(size: 84, avatar: profile.avatar); Spacer() }.listRowBackground(Color.clear)
                TextField("Nickname", text: $profile.nickname).accessibilityIdentifier("profile-child-nickname")
                Stepper("Age: \(profile.age)", value: $profile.age, in: 5...18)
                Picker("Explorer avatar", selection: $profile.avatar) {
                    Text("Mimi").tag("mimi"); Text("Dou Dou").tag("dou-dou"); Text("AJ").tag("aj")
                }
            }
        case .preferences:
            Section("Explanation style") {
                Picker("Explanation style", selection: $profile.learningLevel) {
                    Text("Simple discoveries").tag(1); Text("A little more detail").tag(2); Text("Deeper connections").tag(3)
                }
            }
            Section("Interests") {
                ForEach(ExplorerProfile.interestChoices, id: \.self) { interest in
                    Toggle(L10n.text(interest.capitalized), isOn: Binding(get: {
                        profile.interests.contains(interest)
                    }, set: { selected in
                        profile.interests.removeAll { $0 == interest }
                        if selected { profile.interests.append(interest) }
                    }))
                }
            }
        case .privacy:
            Section("Family permissions") {
                Toggle("Share links", isOn: $policy.sharing)
                Toggle("Friends and text chat", isOn: $policy.social)
                Toggle("Include a nickname in links", isOn: $policy.nameSharing).disabled(!policy.sharing)
                Toggle("Include a city in links", isOn: $policy.citySharing).disabled(!policy.sharing)
                Text("Private photos and exact personal locations stay private.").font(.caption).foregroundStyle(Theme.muted)
            }
            Section("Privacy and support") {
                Link("Privacy policy", destination: URL(string: "https://pocket.changhai.me/privacy")!)
                Link("Contact support", destination: URL(string: "https://pocket.changhai.me/support")!)
            }
        case .cloudAI:
            AIDataPermissionView(family: family)
        case .location:
            Section("Location") {
                Toggle("Publish discoveries on the map", isOn: $policy.mapSharing).disabled(!policy.sharing)
                Toggle("Include a city in links", isOn: $policy.citySharing).disabled(!policy.sharing)
                Text("Private photos and exact personal locations stay private.").font(.caption).foregroundStyle(Theme.muted)
            }
        case .parentControls:
            Section("Family permissions") {
                Toggle("AI exploration", isOn: $policy.exploration)
                Toggle("Nearby events", isOn: $policy.events)
                Toggle("Share links", isOn: $policy.sharing)
                Toggle("Friends and text chat", isOn: $policy.social)
            }
            Section("Screen time") {
                Stepper("Daily minutes: \(policy.dailyMinutes)", value: $policy.dailyMinutes, in: 0...240, step: 5)
                Text("Used today: \(family.usedSeconds / 60) minutes").font(.subheadline)
            }
        }
    }

    private func load() {
        if let current = family.family { profile = current.profile; policy = current.policy }
    }

    private func unlock() {
        guard !working else { return }
        working = true; error = nil
        Task {
            defer { working = false }
            do {
                try await family.unlock(pin: pin, connection: ConnectionVault().loadOrCreate())
                pin = ""
                load()
            } catch { self.error = error.localizedDescription }
        }
    }

    private func save() {
        guard !working else { return }
        working = true; saved = false; error = nil
        Task {
            defer { working = false }
            do {
                try await family.save(profile: profile, policy: policy, connection: ConnectionVault().loadOrCreate())
                UserDefaults.standard.set(profile.age, forKey: "explorer-age")
                saved = true
            } catch { self.error = error.localizedDescription }
        }
    }
}

private struct ProfileAccountSheet: View {
    let profile: ExplorerProfile
    var onLanguage: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Explorer account") {
                    LabeledContent("Nickname", value: profile.nickname)
                    Button { dismiss(); onLanguage() } label: { LabeledContent("Language", value: AppLanguage(rawValue: profile.language)?.name ?? profile.language) }
                        .accessibilityIdentifier("choose-language")
                    LabeledContent("Storage", value: "This iPhone")
                }
            }
            .navigationTitle("Account")
            .toolbar { Button("Done") { dismiss() } }
        }.tint(Theme.forest)
    }
}
