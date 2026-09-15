import SwiftUI

struct ExplorerProfileView: View {
    let store: TripStore
    @Binding var age: Int
    var onClose: () -> Void
    var onLanguage: () -> Void
    var onFamilySettings: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
                    Button(action: onFamilySettings) { row("Family settings", icon: "lock.shield.fill") }
                        .accessibilityIdentifier("open-family-settings")
                    Divider().padding(.horizontal, 16)
                    Button(action: onLanguage) { row("Language", icon: "globe") }.accessibilityIdentifier("choose-language")
                    Divider().padding(.horizontal, 16)
                    NavigationLink { FriendsView(store: store) } label: { row("Friends and text chat", icon: "person.2.fill") }
                        .accessibilityIdentifier("profile-friends")
                    Divider().padding(.horizontal, 16)
                    NavigationLink { DiscoveryRemindersView(store: store) } label: { row("Discovery reminders", icon: "bell.fill") }
                        .accessibilityIdentifier("profile-reminders")
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
