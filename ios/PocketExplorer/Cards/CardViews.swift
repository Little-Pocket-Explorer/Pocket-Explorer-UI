import SwiftUI

struct DiscoveryCard: View {
    let discovery: Discovery
    var reversed = false
    var store: TripStore?
    var compact = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if reversed {
                VStack(alignment: .leading, spacing: 16) {
                    Eyebrow(text: "In my own words")
                    Text(discovery.observation).font(.system(.title2, design: .rounded, weight: .bold)).accessibilityIdentifier("card-observation")
                    Divider()
                    Text(discovery.explanation).font(.system(.body, design: .rounded))
                }.padding(22).frame(maxWidth: .infinity, minHeight: 230, alignment: .leading)
            } else {
                DiscoveryArtwork(discovery: discovery, store: store).aspectRatio(1, contentMode: .fit)
                    .clipped().clipShape(RoundedRectangle(cornerRadius: 19))
                    .overlay(alignment: .topLeading) {
                        Label("V1", systemImage: "leaf.fill").font(.system(.caption2, design: .rounded, weight: .bold))
                            .padding(8).background(Theme.paper.opacity(0.95), in: UnevenRoundedRectangle(bottomTrailingRadius: 10))
                    }.padding(4)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(discovery.title).font(.system(compact ? .subheadline : .title2, design: .rounded, weight: .heavy))
                    .lineLimit(compact && !dynamicTypeSize.isAccessibilitySize ? 2 : nil).fixedSize(horizontal: false, vertical: true)
                Label {
                    Text(discovery.category).fixedSize(horizontal: false, vertical: true)
                } icon: { Image(systemName: "leaf.fill") }
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 9).padding(.vertical, 5).background(Theme.mint, in: Capsule())
                if !compact {
                    Text(discovery.question).font(.system(.subheadline, design: .rounded)).foregroundStyle(Theme.muted)
                    Text(L10n.date(discovery.createdAt)).font(.caption2).foregroundStyle(Theme.muted)
                }
            }.padding(compact ? 10 : 18).frame(maxWidth: .infinity, alignment: .leading)
        }.foregroundStyle(Theme.ink).modifier(BotanicalFrame())
    }
}

struct CardUnlockView: View {
    let discovery: Discovery
    var onReveal: () -> Void
    var store: TripStore?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var unlocking = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Eyebrow(text: "New discovery")
                Text("You discovered a card!").font(.system(.title, design: .rounded, weight: .black)).multilineTextAlignment(.center)
                DiscoveryCard(discovery: discovery, store: store, compact: true).frame(maxWidth: 260)
                    .scaleEffect(unlocking && !reduceMotion ? 1.03 : 1)
                    .rotationEffect(.degrees(unlocking && !reduceMotion ? -2 : 0))
                    .accessibilityIdentifier("card-unlock-stage")
                if let store { ArtworkStatusView(discovery: discovery, store: store) }
                Text("Your collection grows with you.").font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundStyle(Theme.muted)
            }.padding(22).padding(.top, 6)
        }.safeAreaInset(edge: .bottom) {
            Button(action: reveal) { Label("View Card", systemImage: "sparkles") }
                .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("reveal-card").disabled(unlocking)
                .padding(.horizontal, 26).padding(.vertical, 12).background(Theme.paper.opacity(0.97))
        }.background(ExplorerBackdrop()).foregroundStyle(Theme.ink)
    }

    private func reveal() {
        guard !unlocking else { return }
        if reduceMotion { unlocking = true; onReveal(); return }
        withAnimation(.spring(duration: 0.4, bounce: 0.2)) { unlocking = true }
        Task { @MainActor in
            do { try await Task.sleep(for: .milliseconds(350)); onReveal() } catch {}
        }
    }
}

struct CardDetailView: View {
    let store: TripStore
    let discoveryID: UUID
    var isNew = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var reversed = false
    @State private var editing = false
    @State private var observation = ""
    @State private var error: String?
    @State private var section = 0
    private var discovery: Discovery? { store.state.discoveries.first { $0.id == discoveryID } }

    var body: some View {
        ScrollView {
            if let discovery {
                VStack(alignment: .leading, spacing: 24) {
                    Button {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { reversed.toggle() }
                    } label: { DiscoveryCard(discovery: discovery, reversed: reversed, store: store) }
                    .buttonStyle(.plain).accessibilityLabel(L10n.text(reversed ? "Show card front" : "Flip card to read my observation")).accessibilityIdentifier("discovery-card")
                    if discovery.ai != nil {
                        Text("AI illustration · inspired by your discovery").font(.caption2).foregroundStyle(Theme.muted)
                        ArtworkStatusView(discovery: discovery, store: store)
                    }
                    Picker("Card details", selection: $section) {
                        Text("Story").tag(0); Text("Knowledge").tag(1); Text("Location").tag(2)
                    }.pickerStyle(.segmented)
                    VStack(alignment: .leading, spacing: 14) {
                        if section == 0 {
                            Eyebrow(text: "My question")
                            Text(discovery.question).font(.system(.title3, design: .rounded, weight: .bold))
                            if discovery.observation != discovery.question { Text(discovery.observation) }
                            Button("Add to my story") { observation = discovery.observation; editing = true }.frame(minHeight: 44)
                        } else if section == 1 {
                            Text(discovery.explanation).font(.system(.body, design: .rounded))
                            if let reply = discovery.ai { Text(reply.invitation).foregroundStyle(Theme.forest) }
                        } else {
                            if let place = discovery.place ?? store.state.trips.first(where: { $0.id == discovery.tripID })?.place {
                                Label(place.name, systemImage: "mappin.and.ellipse")
                                Text("Exact coordinates stay in your journal.").font(.caption).foregroundStyle(Theme.muted)
                            } else { Label("No location saved", systemImage: "location.slash") }
                        }
                    }.padding(20).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 22))
                    if let filename = discovery.photoFilename {
                        Eyebrow(text: "My field photo · private")
                        CachedMediaImage(url: store.mediaURL(filename), contentMode: .fit) {
                            Theme.mint.opacity(0.4).frame(height: 160)
                        }.clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    if let trip = store.state.trips.first(where: { $0.id == discovery.tripID }) {
                        NavigationLink { SharePreviewView(trip: trip, discoveries: [discovery], store: store, singleCardID: discovery.id) } label: { Label("Preview & share", systemImage: "square.and.arrow.up") }
                            .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("card-share-preview")
                        NavigationLink("See this adventure") { TripDetailView(store: store, tripID: discovery.tripID) }.frame(maxWidth: .infinity, minHeight: 44)
                    }
                }.padding(24)
            }
        }.background(ExplorerBackdrop()).foregroundStyle(Theme.ink)
        .navigationTitle(discovery?.title ?? L10n.text("My discovery")).navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $editing) {
            NavigationStack {
                Form {
                    Section("In my own words") { TextEditor(text: $observation).frame(minHeight: 160).accessibilityIdentifier("edit-observation") }
                    if let error { Text(error) }
                }.navigationTitle("Look a little closer")
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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var query = ""
    @State private var category = "All"
    @State private var newestFirst = true
    private var discoveries: [Discovery] {
        let filtered = store.state.discoveries.filter {
            (category == "All" || $0.categoryID == category.lowercased()) &&
            (query.isEmpty || ($0.title + " " + $0.question).localizedCaseInsensitiveContains(query))
        }.sorted { $0.createdAt < $1.createdAt }
        return newestFirst ? filtered.reversed() : filtered
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if dynamicTypeSize.isAccessibilitySize {
                    collectionHeading
                } else {
                    HStack {
                        LeafBadge(symbol: "rectangle.stack.fill")
                        collectionHeading
                        Spacer(); ExplorerAvatar()
                    }
                }
                HStack {
                    Image(systemName: "magnifyingglass").font(.system(size: 20)).foregroundStyle(Theme.muted).accessibilityHidden(true)
                    TextField(L10n.text(dynamicTypeSize.isAccessibilitySize ? "Search" : "Search discoveries"), text: $query)
                        .accessibilityLabel("Search discoveries").accessibilityIdentifier("collection-search")
                    Button { newestFirst.toggle() } label: { Image(systemName: "arrow.up.arrow.down").font(.system(size: 22)).frame(width: 44, height: 44) }.accessibilityLabel("Reverse sort order")
                }.padding(.leading, 14).background(.white, in: Capsule())
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["All", "Nature", "Science", "Animals", "Space", "History", "Culture"], id: \.self) { item in
                            Button { category = item } label: {
                                Text(L10n.text(item)).font(.system(.caption, design: .rounded, weight: .semibold))
                                    .fixedSize(horizontal: true, vertical: false)
                                    .padding(.horizontal, 16).frame(minHeight: 44).background(category == item ? Theme.mint : .white, in: Capsule())
                            }.buttonStyle(.plain).accessibilityAddTraits(category == item ? .isSelected : [])
                        }
                    }
                }
                if discoveries.isEmpty {
                    ContentUnavailableView("Your next wonder is waiting", systemImage: "leaf", description: Text("Ask a question to grow your collection, or try another search."))
                }
                LazyVGrid(columns: dynamicTypeSize.isAccessibilitySize ? [GridItem(.flexible())] : [GridItem(.flexible(), spacing: 14), GridItem(.flexible())], spacing: 18) {
                    ForEach(discoveries) { discovery in
                        NavigationLink { CardDetailView(store: store, discoveryID: discovery.id) } label: {
                            DiscoveryCard(discovery: discovery, store: store, compact: true)
                        }.buttonStyle(.plain).accessibilityIdentifier("collection-card-\(discovery.id)")
                    }
                }
                Button("Find another wonder", action: explore).buttonStyle(ExplorerButtonStyle())
            }.padding(20)
        }.background(ExplorerBackdrop()).foregroundStyle(Theme.ink).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { DiscoveryRemindersView(store: store) } label: { Label("Discovery Quiz", systemImage: "leaf.arrow.triangle.circlepath") }
                        .accessibilityIdentifier("collection-reminders")
                }
            }
    }

    private var collectionHeading: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Collection").font(.system(dynamicTypeSize.isAccessibilitySize ? .title2 : .largeTitle, design: .rounded, weight: .black))
                .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
            Text("\(store.state.discoveries.count) discoveries").font(.subheadline).foregroundStyle(Theme.muted).accessibilityIdentifier("journal-count")
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BrandHeader: View {
    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "leaf.fill").font(.title2).foregroundStyle(Theme.forest)
            Text("Pocket Explorer").font(.system(.headline, design: .rounded, weight: .black))
            Spacer()
        }.accessibilityElement(children: .combine).padding(.bottom, 10)
    }
}
