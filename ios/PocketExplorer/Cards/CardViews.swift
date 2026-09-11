import SwiftUI

struct DiscoveryCard: View {
    let discovery: Discovery
    var reversed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label(discovery.subject.category, systemImage: "sparkle")
                Spacer()
                Image(systemName: "seal.fill")
            }
            .font(.system(.caption2, design: .rounded, weight: .bold))
            .padding(16)
            if reversed {
                VStack(alignment: .leading, spacing: 16) {
                    Eyebrow(text: "In my own words")
                    Text(discovery.observation)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .accessibilityIdentifier("card-observation")
                    Divider().overlay(Theme.line)
                    Text(discovery.explanation).font(.system(.body, design: .rounded))
                }
                .padding(22).frame(maxWidth: .infinity, minHeight: 230, alignment: .leading)
            } else {
                Image(discovery.subject.rawValue).resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: 220)
                    .accessibilityLabel(discovery.subject.title)
            }
            VStack(alignment: .leading, spacing: 7) {
                Text(discovery.subject.title).font(.system(.title2, design: .rounded, weight: .heavy))
                Text(discovery.question).font(.system(.subheadline, design: .rounded)).foregroundStyle(Theme.muted)
                HStack {
                    Label((discovery.tier ?? .fieldFind).title.uppercased(), systemImage: "sparkles")
                    Spacer()
                    Text((discovery.origin ?? .exploration).title.uppercased())
                }
                .font(.system(.caption2, design: .rounded, weight: .bold)).padding(.top, 10)
                if let unlockedAt = discovery.unlockedAt {
                    Text(unlockedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(.caption2, design: .rounded)).foregroundStyle(Theme.muted)
                }
            }.padding(20)
        }
        .foregroundStyle(Theme.ink)
        .background(Theme.paper, in: RoundedRectangle(cornerRadius: 25))
        .padding(7)
        .background(Theme.shimmer, in: RoundedRectangle(cornerRadius: 31))
        .overlay(RoundedRectangle(cornerRadius: 31).stroke(.white.opacity(0.85), lineWidth: 1))
        .shadow(color: Theme.ink.opacity(0.12), radius: 18, x: 0, y: 9)
    }
}

struct CardUnlockView: View {
    let discovery: Discovery
    var onReveal: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var unlocking = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 20)
            Eyebrow(text: "Discovery complete")
            Text("A new card is waiting.")
                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                .multilineTextAlignment(.center)
            ZStack {
                RoundedRectangle(cornerRadius: 31)
                    .fill(Theme.shimmer)
                RoundedRectangle(cornerRadius: 25)
                    .fill(Theme.forest)
                    .padding(7)
                VStack(spacing: 18) {
                    Image(systemName: unlocking ? "sparkles" : "lock.fill")
                        .font(.system(size: 44, weight: .bold))
                    Image(discovery.subject.rawValue)
                        .resizable().scaledToFit().frame(height: 150)
                        .opacity(unlocking ? 1 : 0.3)
                    Text(discovery.subject.category)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                .foregroundStyle(Theme.paper)
            }
            .frame(maxWidth: 330, minHeight: 390)
            .scaleEffect(unlocking && !reduceMotion ? 1.04 : 1)
            .rotation3DEffect(.degrees(unlocking && !reduceMotion ? 8 : 0), axis: (x: 0, y: 1, z: 0))
            .shadow(color: Theme.ink.opacity(0.18), radius: 22, y: 12)
            .accessibilityIdentifier("card-unlock-stage")
            Text("You asked, looked closer, and made this discovery your own.")
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(Theme.muted).multilineTextAlignment(.center)
            Button(action: reveal) {
                Label(unlocking ? L10n.text("Unlocking…") : L10n.text("Reveal my card"), systemImage: unlocking ? "sparkles" : "lock.open.fill")
            }
            .buttonStyle(ExplorerButtonStyle())
            .accessibilityIdentifier("reveal-card")
            .disabled(unlocking)
            Spacer(minLength: 12)
        }
        .padding(26).background(Theme.paper).foregroundStyle(Theme.ink)
    }

    private func reveal() {
        guard !unlocking else { return }
        if reduceMotion {
            unlocking = true
            onReveal()
            return
        }
        withAnimation(.spring(duration: 0.55, bounce: 0.35)) { unlocking = true }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(650))
            onReveal()
        }
    }
}

struct CardDetailView: View {
    let store: TripStore
    let discoveryID: UUID
    var isNew = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var reversed = false
    @State private var revealed = false
    @State private var editing = false
    @State private var observation = ""
    @State private var error: String?

    private var discovery: Discovery? { store.state.discoveries.first { $0.id == discoveryID } }

    var body: some View {
        ScrollView {
            if let discovery {
                VStack(alignment: .leading, spacing: 24) {
                    Eyebrow(text: isNew ? "You found a little wonder" : "From your collection")
                    Text(L10n.text(isNew ? "Your very own discovery" : "Every find has\na story."))
                        .font(.system(isNew ? .title2 : .largeTitle, design: .rounded, weight: .heavy))
                    Text("Tap your card to turn it over.").font(.footnote).foregroundStyle(Theme.muted)
                    Button {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { reversed.toggle() }
                    } label: { DiscoveryCard(discovery: discovery, reversed: reversed) }
                    .buttonStyle(.plain)
                    .accessibilityLabel(reversed ? "Show card front" : "Flip card to read my observation")
                    .accessibilityIdentifier("discovery-card")
                    .scaleEffect(revealed || reduceMotion ? 1 : 0.9)
                    .opacity(revealed || reduceMotion ? 1 : 0)
                    .onAppear { withAnimation(reduceMotion ? nil : .spring(duration: 0.6)) { revealed = true } }
                    Button("Add to my story") { observation = discovery.observation; editing = true }
                        .buttonStyle(ExplorerButtonStyle(secondary: true))
                    if let filename = discovery.photoFilename, let data = try? Data(contentsOf: store.mediaURL(filename)), let photo = UIImage(data: data) {
                        Eyebrow(text: "My field photo · private")
                        Image(uiImage: photo).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    NavigationLink("See this adventure") { TripDetailView(store: store, tripID: discovery.tripID) }
                        .buttonStyle(ExplorerButtonStyle())
                }.padding(26)
            }
        }
        .background(Theme.paper).foregroundStyle(Theme.ink)
        .navigationTitle(L10n.text(isNew ? "Your new discovery" : "My discovery")).navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $editing) {
            NavigationStack {
                Form {
                    Section("In my own words") { TextEditor(text: $observation).frame(minHeight: 160).accessibilityIdentifier("edit-observation") }
                    if let error { Text(error) }
                }
                .navigationTitle("Look a little closer")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { editing = false } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            do { try store.updateObservation(discoveryID: discoveryID, observation: observation); editing = false }
                            catch { self.error = error.localizedDescription }
                        }.disabled(observation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }
}

struct CollectionView: View {
    let store: TripStore
    var explore: () -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                BrandHeader()
                Eyebrow(text: "Tiny treasures. Big discoveries.")
                Text("Look what\nyou found.").font(.system(.largeTitle, design: .rounded, weight: .heavy))
                Text("\(store.state.discoveries.count) discoveries, each with a story only you can tell.")
                    .foregroundStyle(Theme.muted).accessibilityIdentifier("journal-count")
                if store.state.discoveries.isEmpty {
                    Image("duck").resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 24))
                    Text("Your first little wonder is out there.").font(.title3)
                }
                ForEach(store.state.discoveries.reversed()) { discovery in
                    NavigationLink { CardDetailView(store: store, discoveryID: discovery.id) } label: {
                        DiscoveryCard(discovery: discovery)
                    }.buttonStyle(.plain)
                }
                Button("Find another wonder", action: explore).buttonStyle(ExplorerButtonStyle())
            }.padding(26)
        }
        .background(Theme.paper).foregroundStyle(Theme.ink).toolbar(.hidden, for: .navigationBar)
    }
}

struct BrandHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "safari.fill").font(.title2).foregroundStyle(Theme.forest)
            Text("pocket explorer").font(.system(.headline, design: .rounded, weight: .heavy))
            Spacer()
            Image(systemName: "sparkle").foregroundStyle(Theme.forest)
        }.accessibilityElement(children: .combine).padding(.bottom, 10)
    }
}
