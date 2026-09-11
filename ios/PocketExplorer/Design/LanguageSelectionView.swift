import SwiftUI

struct LanguageSelectionView: View {
    var onSelect: (LanguagePreference) -> Void
    @State private var selection = LanguageSettings.selection ?? .system

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(verbatim: "Hello, explorer!").font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(Theme.muted)
                        Text(verbatim: "Choose your language\n选择语言")
                            .font(.system(.title2, design: .rounded, weight: .heavy))
                    }
                    Image("duck").resizable().scaledToFit().frame(width: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 24)).accessibilityHidden(true)
                }
                Text(verbatim: "For your words, questions and discoveries.\n用你熟悉的语言，开始探索。")
                    .font(.subheadline).foregroundStyle(Theme.muted)
                option(.system, title: "跟随手机 · Use device language", subtitle: "中文 / English")
                option(.chinese, title: "中文", subtitle: "简体中文 · 普通话语音")
                option(.english, title: "English", subtitle: "English interface and voice")
                Text(verbatim: "You can change this on the home screen.\n以后也能在首页切换。")
                    .font(.footnote).foregroundStyle(Theme.muted)
            }.padding(26)
        }
        .safeAreaInset(edge: .bottom) {
            Button { onSelect(selection) } label: { Text(verbatim: "Continue · 继续") }
                .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("language-continue")
                .padding(24).background(Theme.paper)
        }
        .background(Theme.paper).foregroundStyle(Theme.ink)
    }

    private func option(_ value: LanguagePreference, title: String, subtitle: String) -> some View {
        Button { selection = value } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(verbatim: title).font(.system(.headline, design: .rounded))
                    Text(verbatim: subtitle).font(.caption).foregroundStyle(Theme.muted)
                }
                Spacer(minLength: 0)
                Image(systemName: selection == value ? "checkmark.circle.fill" : "circle")
                    .font(.title2).foregroundStyle(Theme.forest)
            }
            .padding(18).frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .background(selection == value ? Theme.surface : .white, in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(selection == value ? Theme.forest : Theme.line, lineWidth: selection == value ? 2 : 1))
        }
        .buttonStyle(.plain).accessibilityIdentifier("language-\(value.rawValue)")
        .accessibilityAddTraits(selection == value ? .isSelected : [])
    }
}
