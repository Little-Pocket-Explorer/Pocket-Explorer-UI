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
                Color.clear.aspectRatio(1, contentMode: .fit)
                    .overlay {
                        GeometryReader { geometry in
                            DiscoveryArtwork(discovery: discovery, store: store)
                                .frame(width: geometry.size.width, height: geometry.size.height).clipped()
                                .blur(radius: discovery.isUnlocked ? 0 : 6)
                                .overlay { if !discovery.isUnlocked { Image(systemName: "lock.fill").font(.system(size: 30)).padding(16).background(Theme.paper.opacity(0.9), in: Circle()) } }
                        }
                    }
                    .overlay(alignment: .topLeading) {
                        Label("V\(discovery.cardVersion)", systemImage: "leaf.fill").font(.system(.caption2, design: .rounded, weight: .bold))
                            .padding(8).background(Theme.paper.opacity(0.95), in: UnevenRoundedRectangle(bottomTrailingRadius: 10))
                    }.clipShape(RoundedRectangle(cornerRadius: 19)).padding(4)
            }
            VStack(alignment: .leading, spacing: 8) {
                if compact && !dynamicTypeSize.isAccessibilitySize {
                    Text(discovery.title).font(.system(.subheadline, design: .rounded, weight: .heavy))
                        .lineLimit(2, reservesSpace: true).fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(discovery.title).font(.system(compact ? .subheadline : .title2, design: .rounded, weight: .heavy))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Label {
                    Text(discovery.category).fixedSize(horizontal: false, vertical: true)
                } icon: { Image(systemName: "leaf.fill") }
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 9).padding(.vertical, 5).background(Theme.mint, in: Capsule())
                if !compact {
                    if let tier = discovery.tier, tier != .fieldFind { Text(tier.title).font(.caption.bold()).foregroundStyle(Theme.forest) }
                    Text(discovery.question).font(.system(.subheadline, design: .rounded)).foregroundStyle(Theme.muted)
                    Text(L10n.date(discovery.createdAt)).font(.caption2).foregroundStyle(Theme.muted)
                }
            }.padding(compact ? 10 : 18).frame(maxWidth: .infinity, alignment: .leading)
        }.foregroundStyle(Theme.ink).modifier(BotanicalFrame(style: discovery.collectible?.style ?? .forest))
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
    @Environment(\.explorerNavigation) private var navigation
    let store: TripStore
    let discoveryID: UUID
    var isNew = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var reversed = false
    @State private var editing = false
    @State private var observation = ""
    @State private var error: String?
    @State private var section = 0
    @State private var styling = false
    @State private var sharing = false
    @State private var openingMapShare = false
    @State private var openingFriendShare: String?
    private var discovery: Discovery? { store.state.discoveries.first { $0.id == discoveryID } }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if let discovery {
                    VStack(alignment: .leading, spacing: 24) {
                        if !discovery.isUnlocked {
                            Text("Your discovery is saved").font(.title2.bold())
                            NavigationLink(value: ExplorerRoute.recall(discovery.id)) { Label("Quiz me now", systemImage: "sparkles") }
                                .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("pending-quiz")
                        }
                        if store.preparedContentNeedsUpdate(discovery.explorationID) {
                            Label("This discovery needs an update. Your card and memories are safe.", systemImage: "info.circle")
                                .font(.subheadline).fixedSize(horizontal: false, vertical: true)
                                .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.mint, in: RoundedRectangle(cornerRadius: 18))
                                .accessibilityIdentifier("prepared-update-notice")
                        }
                        Button {
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { reversed.toggle() }
                        } label: { DiscoveryCard(discovery: discovery, reversed: reversed, store: store) }
                        .buttonStyle(.plain).accessibilityLabel(L10n.text(reversed ? "Show card front" : "Flip card to read my observation")).accessibilityIdentifier("discovery-card")
                        if discovery.ai != nil {
                            Text("AI illustration · inspired by your discovery").font(.caption2).foregroundStyle(Theme.muted)
                            ArtworkStatusView(discovery: discovery, store: store)
                        }
                        Picker("Card details", selection: $section) {
                            Text("Story").tag(0); Text("Knowledge").tag(1); Text("Versions").tag(2); Text("Location").tag(3)
                        }.pickerStyle(.segmented).id("card-section-start")
                        VStack(alignment: .leading, spacing: 14) {
                            if section == 0 {
                                Eyebrow(text: "My question")
                                Text(discovery.question).font(.system(.title3, design: .rounded, weight: .bold))
                                if discovery.observation != discovery.question { Text(discovery.observation) }
                                Button("Add to my story") { observation = discovery.observation; editing = true }.frame(minHeight: 44)
                            } else if section == 1 {
                                Text(discovery.explanation).font(.system(.body, design: .rounded))
                                if let reply = discovery.ai { Text(reply.invitation).foregroundStyle(Theme.forest) }
                            } else if section == 2 {
                                Eyebrow(text: "Versions")
                                if let card = discovery.collectible {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(card.versions.reversed()) { version in
                                                VStack(alignment: .leading, spacing: 5) {
                                                    Text("V\(version.version)").font(.caption.bold()).foregroundStyle(Theme.forest)
                                                    Text(version.reply.title).font(.subheadline.bold()).lineLimit(2)
                                                    Text(L10n.date(Date(timeIntervalSince1970: version.awardedAt / 1000))).font(.caption2).foregroundStyle(Theme.muted)
                                                }.padding(12).frame(width: 138, alignment: .leading)
                                                    .frame(minHeight: 96, alignment: .leading)
                                                    .background(Theme.mint, in: RoundedRectangle(cornerRadius: 16))
                                            }
                                        }
                                    }
                                    NavigationLink { CardHistoryView(card: card) } label: { Label("Card history", systemImage: "clock.arrow.circlepath") }
                                        .accessibilityIdentifier("card-history-versions")
                                } else {
                                    Text("V1 · \(discovery.title)").font(.headline)
                                }
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
                            Button { sharing = true } label: { Label("Preview & share", systemImage: "square.and.arrow.up") }
                                .buttonStyle(ExplorerButtonStyle()).disabled(!discovery.isUnlocked).accessibilityIdentifier("card-share-preview")
                            NavigationLink("See this adventure", value: ExplorerRoute.trip(discovery.tripID)).frame(maxWidth: .infinity, minHeight: 44)
                        }
                        if let origin = discovery.collectible?.origin { Label(origin.displayLabel, systemImage: origin.kind == "event" ? "mappin.and.ellipse" : "gift").font(.headline) }
                        if let card = discovery.collectible, discovery.isUnlocked {
                            VStack(alignment: .leading, spacing: 14) {
                                NavigationLink { CardHistoryView(card: card) } label: { Label("Card history", systemImage: "clock.arrow.circlepath") }.accessibilityIdentifier("card-history")
                                Button("Help this card grow") { navigation?.open(.explore(.init(tripID: discovery.tripID, parentID: discovery.explorationID, evolveFrom: card.id)), in: .chat) }.buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("evolve-card")
                                    .disabled(!store.family.allows(.exploration))
                                Picker("Card style", selection: Binding(get: { card.style }, set: { style in
                                    styling = true; error = nil
                                    Task {
                                        defer { styling = false }
                                        do { try store.saveCardStyle(await CollectibleClient().style(style, id: card.id, connection: ConnectionVault().loadOrCreate())) }
                                        catch { self.error = error.localizedDescription }
                                    }
                                })) { ForEach(CardStyle.allCases) { style in Text(style.title).tag(style) } }.disabled(styling).accessibilityIdentifier("card-style")
                                if let error { Text(error).font(.caption) }
                            }.padding(20).background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 22))
                        }
                    }.padding(24)
                }
            }.onChange(of: section) { _, _ in
                proxy.scrollTo("card-section-start", anchor: .top)
            }.background(ExplorerBackdrop()).foregroundStyle(Theme.ink)
            .navigationTitle(discovery?.title ?? L10n.text("My discovery")).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if discovery?.isUnlocked == true {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { sharing = true } label: { Image(systemName: "square.and.arrow.up").frame(minWidth: 44, minHeight: 44) }
                            .accessibilityLabel("Share card").accessibilityIdentifier("card-share-options")
                    }
                }
            }
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
            .sheet(isPresented: $sharing, onDismiss: {
                if openingMapShare {
                    openingMapShare = false
                    navigation?.open(.mapShare(discoveryID))
                } else if let friendID = openingFriendShare {
                    openingFriendShare = nil
                    navigation?.open(.friend(friendID, 0), in: .social)
                }
            }) {
                if let discovery, let trip = store.state.trips.first(where: { $0.id == discovery.tripID }) {
                    CardShareOptionsView(store: store, discovery: discovery, trip: trip, onMap: {
                        openingMapShare = true
                    }, onFriendSent: { friendID in
                        openingFriendShare = friendID
                    })
                    .presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
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
    @State private var showingQuizPrompt = false
    @State private var prompted = false
    private var readyQuizCount: Int { store.state.discoveries.filter { ReminderPolicy.isEligible($0, now: Date()) }.count }
    private var discoveries: [Discovery] {
        var seen = Set<String>()
        let latest = store.state.discoveries.sorted {
            $0.isUnlocked == $1.isUnlocked ? $0.createdAt > $1.createdAt : $0.isUnlocked
        }.filter { seen.insert($0.collectionID).inserted }
        let filtered = latest.filter {
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
                Button { showingQuizPrompt = true } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "leaf.arrow.triangle.circlepath").font(.title2).foregroundStyle(Theme.forest)
                            .frame(width: 46, height: 46).background(Theme.mint, in: Circle())
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Discovery Quizzes").font(.headline)
                            if readyQuizCount > 0 {
                                (Text(readyQuizCount.formatted()) + Text(" ready · Tap to start")).font(.caption).foregroundStyle(Theme.muted)
                            } else { Text("Ready when you are").font(.caption).foregroundStyle(Theme.muted) }
                        }
                        Spacer(); Image(systemName: "chevron.right").foregroundStyle(Theme.muted)
                    }.padding(13).background(.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 22))
                }.buttonStyle(.plain).accessibilityIdentifier("collection-quiz-notification")
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
                        NavigationLink(value: ExplorerRoute.card(discovery.id)) {
                            DiscoveryCard(discovery: discovery, store: store, compact: true)
                                .contentShape(RoundedRectangle(cornerRadius: 29))
                        }.buttonStyle(.plain).accessibilityIdentifier("collection-card-\(discovery.id)")
                    }
                }
                Button("Find another wonder", action: explore).buttonStyle(ExplorerButtonStyle())
            }.padding(20)
        }.background(ExplorerBackdrop()).foregroundStyle(Theme.ink).navigationBarTitleDisplayMode(.inline)
            .onAppear {
                guard !prompted else { return }
                prompted = true
                showingQuizPrompt = readyQuizCount > 0
            }
            .sheet(isPresented: $showingQuizPrompt) {
                NavigationStack { DiscoveryRemindersView(store: store, close: { showingQuizPrompt = false }) }
                    .presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: ExplorerRoute.reminders) { Label("Discovery Quiz", systemImage: "leaf.arrow.triangle.circlepath") }
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
