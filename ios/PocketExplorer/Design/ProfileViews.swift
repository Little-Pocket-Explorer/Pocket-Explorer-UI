import SwiftUI

struct ExplorerProfileView: View {
    let profile: ExplorerProfile
    let discoveries: Int
    var onClose: () -> Void
    var onPrivacy: () -> Void
    var onChildProfile: () -> Void
    var onPreferences: () -> Void
    var onNotifications: () -> Void
    var onLocation: () -> Void
    var onParentControls: () -> Void
    var onAccount: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack { Button(action: onClose) { Image(systemName: "xmark") }.frame(width: 44, height: 44).background(.white, in: Circle()); Spacer(); Text("Profile").font(.system(.title2, design: .rounded, weight: .heavy)); Spacer(); Color.clear.frame(width: 44, height: 44) }
                VStack(spacing: 5) {
                    ProfilePortrait()
                    Text(profile.displayName).font(.system(.largeTitle, design: .rounded, weight: .heavy))
                    Text("Age \(profile.age ?? 7)").font(.title3).foregroundStyle(Theme.muted)
                }
                HStack(spacing: 0) {
                    stat("\(discoveries)", "Discoveries", icon: "leaf.fill")
                    Divider().frame(height: 47)
                    stat("0", "Places", icon: "mappin.circle.fill")
                    Divider().frame(height: 47)
                    stat("0", "Rare", icon: "star.fill")
                }.padding(.vertical, 15).background(.white, in: RoundedRectangle(cornerRadius: 23))
                VStack(alignment: .leading, spacing: 10) {
                    Text("Interests").font(.headline)
                    FlowLayout(spacing: 9) {
                        ForEach(profile.interests ?? []) { interest in
                            Label(interest.title, systemImage: interest.icon).font(.subheadline).padding(.horizontal, 13).padding(.vertical, 9)
                                .background(interest == .animals ? Theme.sun.opacity(0.25) : Theme.mint, in: Capsule())
                        }
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 0) {
                    Button(action: onChildProfile) { row("Child Profile", icon: "person.fill") }.buttonStyle(.plain).accessibilityIdentifier("open-child-profile")
                    Button(action: onPreferences) { row("Discovery Preferences", icon: "leaf.fill") }.buttonStyle(.plain).accessibilityIdentifier("open-preferences")
                    Button(action: onNotifications) { row("Notifications", icon: "bell.fill") }.buttonStyle(.plain).accessibilityIdentifier("open-notifications")
                    Button(action: onPrivacy) { row("Privacy", icon: "checkmark.shield.fill") }.buttonStyle(.plain).accessibilityIdentifier("open-privacy")
                    row("Friends & Family", icon: "person.2.fill", disabled: true)
                    Button(action: onLocation) { row("Location", icon: "mappin.circle.fill") }.buttonStyle(.plain).accessibilityIdentifier("open-location")
                    Button(action: onParentControls) { row("Parent Controls", icon: "lock.fill") }.buttonStyle(.plain).accessibilityIdentifier("open-parent-controls")
                    Button(action: onAccount) { row("Account", icon: "lock.fill") }.buttonStyle(.plain).accessibilityIdentifier("open-account")
                }.background(.white, in: RoundedRectangle(cornerRadius: 23))
            }.padding(20)
        }.background(ProfileBackdrop()).foregroundStyle(Theme.ink).symbolRenderingMode(.hierarchical)
    }

    private func stat(_ value: String, _ label: String, icon: String) -> some View {
        VStack(spacing: 4) { Label(value, systemImage: icon).font(.system(.title2, design: .rounded, weight: .heavy)); Text(label).font(.caption).foregroundStyle(Theme.muted) }.frame(maxWidth: .infinity)
    }

    private func row(_ label: String, icon: String, disabled: Bool = false) -> some View {
        HStack(spacing: 13) { Image(systemName: icon).foregroundStyle(Theme.forest).frame(width: 30); Text(label); Spacer(); Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.muted) }
            .padding(15).frame(maxWidth: .infinity, minHeight: 52, alignment: .leading).opacity(disabled ? 0.45 : 1).accessibilityElement(children: .combine)
    }
}

struct PrivacySettingsView: View {
    let profile: ExplorerProfile
    var onClose: () -> Void
    var onSave: (ExplorerProfile) -> Void
    @State private var privacy: ExplorerPrivacy
    @State private var saved = false

    init(profile: ExplorerProfile, onClose: @escaping () -> Void, onSave: @escaping (ExplorerProfile) -> Void) {
        self.profile = profile
        self.onClose = onClose
        self.onSave = onSave
        _privacy = State(initialValue: profile.privacy)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack { Button(action: onClose) { Image(systemName: "chevron.left") }.frame(width: 44, height: 44).background(.white, in: Circle()); Text("Privacy & controls").font(.system(.title2, design: .rounded, weight: .heavy)); Spacer() }
                HStack(spacing: 13) { ProfilePortrait(size: 62); VStack(alignment: .leading) { Text("Settings for \(profile.displayName)").font(.headline); Text("Age \(profile.age ?? 7)").foregroundStyle(Theme.muted) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted) }
                    .padding(12).background(.white, in: RoundedRectangle(cornerRadius: 22))
                section("Who can see discoveries?", icon: "leaf.fill", detail: "Choose who can see what \(profile.displayName) finds and creates.") {
                    Picker("Discovery audience", selection: $privacy.audience) { ForEach(DiscoveryAudience.allCases) { Text($0.title).tag($0) } }.pickerStyle(.segmented).accessibilityIdentifier("privacy-audience")
                }
                section(icon: "mappin.circle.fill") {
                    toggleRow("Share location", icon: "mappin.circle.fill", value: $privacy.shareLocation).accessibilityIdentifier("privacy-location")
                    Text("Locations stay private unless you turn this on.").font(.caption).foregroundStyle(Theme.muted)
                }
                section("Permissions", icon: "checkmark.shield.fill", detail: "Choose what \(profile.displayName) can do in the app.") {
                    permission("Allow social", icon: "message.fill", detail: "Local preference for future social features.", value: $privacy.allowSocial, id: "privacy-social")
                    permission("Public sharing", icon: "square.and.arrow.up.fill", detail: "Each story still needs its own share action.", value: $privacy.allowPublicSharing, id: "privacy-public-sharing")
                    permission("Friend requests", icon: "person.2.fill", detail: "Local preference for future friend features.", value: $privacy.allowFriendRequests, id: "privacy-friend-requests")
                    permission("Notifications", icon: "bell.fill", detail: "Receive app updates and reminders.", value: $privacy.notifications, id: "privacy-notifications")
                }
                section("AI & usage", icon: "brain.head.profile", detail: "Set age-appropriate content and screen time limits.") {
                    Label("AI content level", systemImage: "leaf.fill").font(.subheadline.bold()).frame(maxWidth: .infinity, alignment: .leading)
                    LabeledContent("", value: "Age \(profile.age ?? 7)").padding(.vertical, 3)
                    Divider()
                    HStack { Label("Daily usage", systemImage: "clock.fill").font(.subheadline.bold()); Spacer(); Picker("Daily usage", selection: $privacy.dailyMinutes) { ForEach([15, 30, 45, 60], id: \.self) { Text("\($0) min").tag($0) } }.labelsHidden().accessibilityIdentifier("privacy-daily-usage") }
                }
                Button("Save changes") { do { onSave(try ProfileSettings.savePrivacy(privacy, for: profile)); saved = true } catch { } }
                    .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("privacy-save")
                if saved { Text("Privacy settings saved.").font(.caption).foregroundStyle(Theme.forest).accessibilityIdentifier("privacy-saved") }
            }.padding(20)
        }.background(ProfileBackdrop()).foregroundStyle(Theme.ink).symbolRenderingMode(.hierarchical)
    }

    private func section<Content: View>(_ title: String = "", icon: String, detail: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if !title.isEmpty { HStack(alignment: .top, spacing: 10) { Image(systemName: icon).foregroundStyle(Theme.forest).frame(width: 36, height: 36).background(Theme.mint, in: Circle()); VStack(alignment: .leading, spacing: 2) { Text(title).font(.headline); if let detail { Text(detail).font(.caption).foregroundStyle(Theme.muted) } }; Spacer() } }
            content()
        }
            .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 22))
    }

    private func permission(_ label: String, icon: String, detail: String, value: Binding<Bool>, id: String) -> some View {
        VStack(spacing: 4) { toggleRow(label, icon: icon, value: value).accessibilityIdentifier(id); Text(detail).font(.caption).foregroundStyle(Theme.muted).frame(maxWidth: .infinity, alignment: .leading); if label != "Notifications" { Divider().padding(.top, 6) } }
    }

    private func toggleRow(_ label: String, icon: String, value: Binding<Bool>) -> some View {
        HStack { Label(label, systemImage: icon).font(.subheadline.bold()); Spacer(); Toggle(label, isOn: value).labelsHidden() }
    }
}

struct ProfileDetailView: View {
    enum Kind { case child, preferences, notifications, location, parentControls, account }
    let kind: Kind
    let profile: ExplorerProfile
    var onClose: () -> Void
    var onSave: (ExplorerProfile) -> Void
    @State private var nickname: String
    @State private var age: Int
    @State private var interests: Set<ExplorerInterest>
    @State private var notifications: Bool
    @State private var location: Bool
    @State private var publicSharing: Bool
    @State private var dailyMinutes: Int

    init(kind: Kind, profile: ExplorerProfile, onClose: @escaping () -> Void, onSave: @escaping (ExplorerProfile) -> Void) {
        self.kind = kind; self.profile = profile; self.onClose = onClose; self.onSave = onSave
        _nickname = State(initialValue: profile.displayName); _age = State(initialValue: profile.age ?? 7)
        _interests = State(initialValue: Set(profile.interests ?? [])); _notifications = State(initialValue: profile.privacy.notifications); _location = State(initialValue: profile.privacy.shareLocation); _publicSharing = State(initialValue: profile.privacy.allowPublicSharing); _dailyMinutes = State(initialValue: profile.privacy.dailyMinutes)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack { Button(action: onClose) { Image(systemName: "chevron.left") }.frame(width: 44, height: 44); Text(title).font(.system(.title2, design: .rounded, weight: .heavy)); Spacer() }
                content
                Button(saveTitle, action: save).buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("profile-detail-save")
            }.padding(20)
        }.background(ProfileBackdrop()).foregroundStyle(Theme.ink).symbolRenderingMode(.hierarchical)
    }

    @ViewBuilder private var content: some View {
        switch kind {
        case .child:
            ProfilePortrait(size: 100).frame(maxWidth: .infinity)
            TextField("Nickname", text: $nickname).padding(15).background(.white, in: RoundedRectangle(cornerRadius: 18)).accessibilityIdentifier("detail-nickname")
            Stepper("Age \(age)", value: $age, in: 3...18)
        case .preferences:
            Text("Choose the topics that make the next questions feel exciting.").foregroundStyle(Theme.muted)
            interestChips
        case .notifications:
            Toggle("Discovery reminders", isOn: $notifications).padding(16).background(.white, in: RoundedRectangle(cornerRadius: 20))
            Text("A local preference for gentle prompts to revisit discoveries.").font(.caption).foregroundStyle(Theme.muted)
        case .location:
            Toggle("Share location", isOn: $location).padding(16).background(.white, in: RoundedRectangle(cornerRadius: 20))
            Text("Locations stay private unless you turn this on.").font(.caption).foregroundStyle(Theme.muted)
        case .parentControls:
            Text("Family preferences").font(.title3.bold())
            Text("These local preferences guide the experience. They do not require approval to explore or share a story.").foregroundStyle(Theme.muted)
            VStack(spacing: 0) {
                Picker("Daily usage", selection: $dailyMinutes) { ForEach([15, 30, 45, 60], id: \.self) { Text("\($0) min").tag($0) } }.padding(12)
                Divider()
                Toggle("Discovery reminders", isOn: $notifications).padding(12)
                Divider()
                Toggle("Public sharing", isOn: $publicSharing).padding(12)
            }.background(.white, in: RoundedRectangle(cornerRadius: 20))
        case .account:
            LabeledContent("Email", value: profile.email).padding(16).background(.white, in: RoundedRectangle(cornerRadius: 20))
            Text("This is a local profile on this iPhone.").foregroundStyle(Theme.muted)
        }
    }

    private var interestChips: some View {
        FlowLayout(spacing: 9) { ForEach(ExplorerInterest.allCases) { interest in Button { if interests.contains(interest) { interests.remove(interest) } else { interests.insert(interest) } } label: { Label(interest.title, systemImage: interest.icon).padding(.horizontal, 12).padding(.vertical, 9).background(interests.contains(interest) ? Theme.mint : .white, in: Capsule()) }.buttonStyle(.plain) } }
    }

    private var title: String { kind == .child ? "Child profile" : kind == .preferences ? "Discovery preferences" : kind == .notifications ? "Notifications" : kind == .location ? "Location" : kind == .parentControls ? "Parent controls" : "Account" }
    private var saveTitle: String { kind == .child ? "Save child profile" : kind == .preferences ? "Save preferences" : kind == .notifications ? "Save notifications" : kind == .location ? "Save location" : kind == .parentControls ? "Save parent controls" : "Done" }
    private func save() {
        var updated = profile
        if kind == .child { updated.displayName = nickname; updated.age = age }
        if kind == .preferences { updated.interests = Array(interests).sorted { $0.rawValue < $1.rawValue } }
        if kind == .notifications { updated.privacy.notifications = notifications }
        if kind == .location { updated.privacy.shareLocation = location }
        if kind == .parentControls { updated.privacy.notifications = notifications; updated.privacy.allowPublicSharing = publicSharing; updated.privacy.dailyMinutes = dailyMinutes }
        if let saved = try? ProfileSettings.save(updated) { onSave(saved) } else { onClose() }
    }
}