import SwiftUI

struct ChildProfileView: View {
    let profile: ExplorerProfile
    var onBack: () -> Void
    var onComplete: (ExplorerProfile) -> Void
    @State private var nickname: String
    @State private var avatar: ExplorerAvatar = .mimi
    @State private var age = 7
    @State private var gender: ExplorerGender = .preferNotToSay
    @State private var interests = Set([ExplorerInterest.bugs, .nature])
    @State private var error: String?

    init(profile: ExplorerProfile, onBack: @escaping () -> Void, onComplete: @escaping (ExplorerProfile) -> Void) {
        self.profile = profile
        self.onBack = onBack
        self.onComplete = onComplete
        _nickname = State(initialValue: profile.displayName)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack { Button(action: onBack) { Image(systemName: "chevron.left") }.frame(width: 44, height: 44).accessibilityIdentifier("profile-back"); Spacer(); Text("Step 2 of 2").font(.caption).foregroundStyle(Theme.muted); Spacer(); Color.clear.frame(width: 44, height: 44) }
                BrandHeader()
                Text("Create a child profile").font(.system(.title, design: .rounded, weight: .heavy))
                Text("Pocket Explorer adapts to their age and interests.").font(.subheadline).foregroundStyle(Theme.muted)
                HStack(spacing: 13) {
                    ForEach(ExplorerAvatar.allCases) { option in
                        Button { avatar = option } label: {
                            VStack(spacing: 6) {
                                Image(option.imageName).resizable().scaledToFill().frame(width: 78, height: 78).clipShape(Circle()).overlay(Circle().stroke(avatar == option ? Theme.forest : .white, lineWidth: avatar == option ? 3 : 1))
                                Text(option.title).font(.caption.bold())
                            }
                        }.buttonStyle(.plain).accessibilityIdentifier("profile-avatar-\(option.rawValue)")
                    }
                }
                profileRow("Nickname", icon: "person.fill") { TextField("Nickname", text: $nickname).multilineTextAlignment(.trailing).accessibilityIdentifier("profile-nickname") }
                profileRow("Age", icon: "calendar") { Stepper(value: $age, in: 3...18) { Text("\(age)") }.labelsHidden().accessibilityIdentifier("profile-age") }
                profileRow("Gender", icon: "person.2.fill") { Picker("Gender", selection: $gender) { ForEach(ExplorerGender.allCases) { Text($0.title).tag($0) } }.labelsHidden() }
                VStack(alignment: .leading, spacing: 10) {
                    HStack { Text("Interests").font(.subheadline.bold()); Text("optional").font(.caption).foregroundStyle(Theme.muted) }
                    FlowLayout(spacing: 9) {
                        ForEach(ExplorerInterest.allCases) { interest in
                            Button { if interests.contains(interest) { interests.remove(interest) } else { interests.insert(interest) } } label: { Label(interest.title, systemImage: interest.icon).font(.caption.bold()).padding(.horizontal, 12).padding(.vertical, 9).background(interests.contains(interest) ? Theme.mint : .white, in: Capsule()).overlay(Capsule().stroke(interests.contains(interest) ? Theme.forest : Theme.line)) }
                                .buttonStyle(.plain).accessibilityIdentifier("profile-interest-\(interest.rawValue)")
                        }
                    }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.top, 8)
                if let error { Text(error).font(.caption).foregroundStyle(.orange) }
                Button(action: finish) { Label("Start exploring", systemImage: "arrow.right") }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("profile-start")
                Text("Your profile stays on this iPhone.").font(.caption2).foregroundStyle(Theme.muted)
            }.padding(22)
        }.background(ExplorerBackdrop()).foregroundStyle(Theme.ink)
    }

    private func profileRow<Content: View>(_ title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) { Image(systemName: icon).foregroundStyle(Theme.forest).frame(width: 34, height: 34).background(Theme.mint, in: Circle()); Text(title).font(.subheadline.bold()); Spacer(); content(); Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.muted) }
            .padding(12).background(.white, in: RoundedRectangle(cornerRadius: 18))
    }

    private func finish() {
        do { onComplete(try ProfileSettings.complete(profile, nickname: nickname, avatar: avatar, age: age, gender: gender == .preferNotToSay ? nil : gender, interests: Array(interests))) }
        catch { self.error = error.localizedDescription }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = rows(width: proposal.width ?? 320, subviews: subviews)
        return CGSize(width: proposal.width ?? 320, height: rows.reduce(0) { $0 + $1.height + spacing } - spacing)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(width: bounds.width, subviews: subviews) { var x = bounds.minX; for view in row.views { view.place(at: CGPoint(x: x, y: y), proposal: .unspecified); x += view.sizeThatFits(.unspecified).width + spacing }; y += row.height + spacing }
    }
    private func rows(width: CGFloat, subviews: Subviews) -> [(views: [Subview], height: CGFloat)] {
        var result: [(views: [Subview], height: CGFloat)] = []; var row: [Subview] = []; var used: CGFloat = 0; var height: CGFloat = 0
        for view in subviews { let size = view.sizeThatFits(.unspecified); if !row.isEmpty, used + spacing + size.width > width { result.append((row, height)); row = []; used = 0; height = 0 }; row.append(view); used += (row.count == 1 ? 0 : spacing) + size.width; height = max(height, size.height) }
        if !row.isEmpty { result.append((row, height)) }; return result
    }
}