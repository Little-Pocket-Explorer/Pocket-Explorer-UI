import SwiftUI

struct ArtworkStatusView: View {
    let discovery: Discovery
    let store: TripStore
    @Environment(ArtworkCoordinator.self) private var coordinator: ArtworkCoordinator?

    var body: some View {
        if discovery.ai != nil, discovery.artworkFilename == nil {
            TimelineView(.periodic(from: .now, by: 5)) { timeline in
                let progress = ArtworkProgress.resolve(discovery, error: coordinator?.errors[discovery.id], stopped: coordinator?.stopped.contains(discovery.id) == true, now: timeline.date)
                VStack(alignment: .leading, spacing: 12) {
                    Label(L10n.text(progress.title), systemImage: progress.symbol)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .accessibilityIdentifier("artwork-status-title")
                    Text(coordinator?.errors[discovery.id] ?? L10n.text(progress.message)).font(.subheadline).foregroundStyle(Theme.muted)
                    if let action = progress.action {
                        Button {
                            Task { await coordinator?.update(discovery, store: store, retry: true) }
                        } label: {
                            HStack {
                                Text(L10n.text(action)).font(.subheadline.bold())
                                Spacer()
                                if coordinator?.busy.contains(discovery.id) == true { ProgressView() }
                                else { Image(systemName: "arrow.clockwise") }
                            }.frame(minHeight: 44).contentShape(Rectangle())
                        }.buttonStyle(.plain).foregroundStyle(Theme.forest)
                            .disabled(coordinator?.busy.contains(discovery.id) == true).accessibilityIdentifier("retry-artwork")
                    }
                }.padding(18).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.mint.opacity(0.65), in: RoundedRectangle(cornerRadius: 22))
            }
        }
    }
}
