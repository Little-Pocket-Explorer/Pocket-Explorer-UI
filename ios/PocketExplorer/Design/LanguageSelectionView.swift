import SwiftUI

struct LanguageSelectionView: View {
    var onSelect: (LanguagePreference) -> Void
    @State private var selection = LanguageSettings.selection ?? .system
    private var language: AppLanguage { selection.resolve(Locale.preferredLanguages) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.text("Hello, explorer!", language: language))
                            .font(.system(.caption, design: .rounded, weight: .bold)).foregroundStyle(Theme.muted)
                        Text(L10n.text("Choose your language", language: language))
                            .font(.system(.title2, design: .rounded, weight: .heavy))
                    }
                    Image("duck").resizable().scaledToFit().frame(width: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 24)).accessibilityHidden(true)
                }
                Text(L10n.text("For your words, questions and discoveries.", language: language))
                    .font(.subheadline).foregroundStyle(Theme.muted)
                ForEach(LanguagePreference.allCases) { value in option(value) }
                Text(L10n.text("You can change this on the home screen.", language: language))
                    .font(.footnote).foregroundStyle(Theme.muted)
            }.padding(26)
        }
        .safeAreaInset(edge: .bottom) {
            Button { onSelect(selection) } label: { Text(L10n.text("Continue", language: language)) }
                .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("language-continue")
                .padding(24).background(Theme.paper)
        }
        .background(Theme.paper).foregroundStyle(Theme.ink)
        .environment(\.layoutDirection, language.isRightToLeft ? .rightToLeft : .leftToRight)
    }

    private func option(_ value: LanguagePreference) -> some View {
        Button { selection = value } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(verbatim: value.language?.name ?? L10n.text("Use device language", language: language))
                        .font(.system(.headline, design: .rounded))
                    if value == .system {
                        Text(verbatim: AppLanguage.resolve(Locale.preferredLanguages).name).font(.caption).foregroundStyle(Theme.muted)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: selection == value ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26)).frame(width: 28).foregroundStyle(Theme.forest)
            }
            .padding(18).frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .background(selection == value ? Theme.surface : .white, in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(selection == value ? Theme.forest : Theme.line, lineWidth: selection == value ? 2 : 1))
        }
        .buttonStyle(.plain).accessibilityIdentifier("language-\(value.rawValue)")
        .accessibilityAddTraits(selection == value ? .isSelected : [])
    }
}
