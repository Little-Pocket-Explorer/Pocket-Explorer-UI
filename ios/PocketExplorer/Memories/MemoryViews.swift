import SwiftUI

struct MemoriesView: View {
    let store: TripStore
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                BrandHeader()
                Eyebrow(text: "A little look back")
                Text("Small moments.\nBig feelings.").font(.system(.largeTitle, design: .rounded, weight: .heavy))
                Text("The questions, the adventures, the things you noticed. All yours to keep.").foregroundStyle(Theme.muted)
                ForEach(store.state.trips.filter { $0.memory != nil }) { trip in
                    NavigationLink { MemoryPlayer(trip: trip) } label: {
                        VStack(alignment: .leading, spacing: 0) {
                            Image((store.discoveries(in: trip.id).first?.subject ?? .duck).rawValue).resizable().scaledToFit()
                                .overlay(alignment: .bottomTrailing) {
                                    Image(systemName: "play.fill").foregroundStyle(Theme.paper)
                                        .frame(width: 54, height: 54).background(Theme.forest, in: Circle()).padding(20)
                                }
                            VStack(alignment: .leading, spacing: 9) {
                                Eyebrow(text: "A memory, made by you")
                                Text(trip.title).font(.system(.title2, design: .rounded, weight: .heavy))
                                Text("\(store.discoveries(in: trip.id).count) discoveries · Tap to relive it").font(.footnote).foregroundStyle(Theme.muted)
                            }.padding(22)
                        }.background(.white.opacity(0.8)).clipShape(RoundedRectangle(cornerRadius: 29))
                    }.buttonStyle(.plain).accessibilityIdentifier("memory-\(trip.id)")
                    NavigationLink("Preview & share") { SharePreviewView(trip: trip, discoveries: store.discoveries(in: trip.id)) }
                        .buttonStyle(ExplorerButtonStyle(secondary: true))
                }
                if !store.state.trips.contains(where: { $0.memory != nil }) {
                    ContentUnavailableView("A memory is waiting to happen", systemImage: "sparkles", description: Text("Finish an adventure to keep its story here."))
                }
            }.padding(26)
        }.background(Theme.paper).foregroundStyle(Theme.ink).toolbar(.hidden, for: .navigationBar)
    }
}

struct MemoryPlayer: View {
    let trip: Trip
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var playback: MemoryPlayback
    @State private var timerTask: Task<Void, Never>?

    init(trip: Trip) {
        self.trip = trip
        _playback = State(initialValue: MemoryPlayback(count: trip.memory?.chapters.count ?? 0))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Eyebrow(text: "A memory, made by you")
                Text(trip.title).font(.system(.title2, design: .rounded, weight: .heavy))
                if let chapters = trip.memory?.chapters, chapters.indices.contains(playback.index) {
                    let chapter = chapters[playback.index]
                    HStack(spacing: 5) {
                        ForEach(chapters.indices, id: \.self) { index in
                            Capsule().fill(index <= playback.index ? Theme.forest : Theme.line).frame(height: 5)
                        }
                    }.accessibilityLabel("Chapter \(playback.index + 1) of \(chapters.count)")
                    Image(chapter.subject.rawValue).resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: 170)
                        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 24))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    VStack(alignment: .leading, spacing: 15) {
                        Eyebrow(text: chapter.title)
                        Text(chapter.text).font(.system(.title2, design: .rounded, weight: .bold))
                            .accessibilityIdentifier("memory-chapter")
                    }.id(chapter.id).transition(.opacity)
                }
            }.padding(26)
        }
        .safeAreaInset(edge: .bottom) {
            if let chapters = trip.memory?.chapters, !chapters.isEmpty {
                HStack(spacing: 8) {
                    Button { stopTimer(); playback.select(playback.index - 1) } label: { Image(systemName: "backward.end.fill").frame(width: 48, height: 50) }
                        .accessibilityLabel("Previous chapter").disabled(playback.index == 0)
                    Button {
                        if playback.isPlaying { stopTimer(); playback.pause() }
                        else { playback.play(); startTimer() }
                    } label: { Label(L10n.text(playback.isPlaying ? "Pause" : "Play"), systemImage: playback.isPlaying ? "pause.fill" : "play.fill") }
                        .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("memory-play-pause")
                    Button { stopTimer(); playback.select(playback.index + 1) } label: { Image(systemName: "forward.end.fill").frame(width: 48, height: 50) }
                        .accessibilityLabel("Next chapter").disabled(playback.index >= chapters.count - 1)
                    Button { playback.replay(); startTimer() } label: { Image(systemName: "arrow.counterclockwise").frame(width: 44, height: 50) }
                        .accessibilityLabel("Replay from the beginning").accessibilityIdentifier("memory-replay")
                }
                .padding(.horizontal, 20).padding(.vertical, 10).background(Theme.paper)
            }
        }
        .background(Theme.paper).foregroundStyle(Theme.ink)
        .navigationTitle("My little memory").navigationBarTitleDisplayMode(.inline)
        .onDisappear { stopTimer(); playback.pause() }
        .onChange(of: scenePhase) { _, next in if next != .active { stopTimer(); playback.pause() } }
    }

    private func startTimer() {
        stopTimer()
        timerTask = Task { @MainActor in
            while !Task.isCancelled && playback.isPlaying {
                do { try await Task.sleep(for: .seconds(5)) } catch { return }
                guard !Task.isCancelled else { return }
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { playback.tick() }
            }
        }
    }
    private func stopTimer() { timerTask?.cancel(); timerTask = nil }
}
