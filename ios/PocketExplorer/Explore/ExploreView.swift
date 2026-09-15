import AVFoundation
import PhotosUI
import SwiftUI

enum ExplorationEntry {
    case compose, voice, camera, question
}

struct ExploreView: View {
    let store: TripStore
    let tripID: UUID?
    var initialQuestion = ""
    var recordID: UUID?
    var presentAnswerOnOpen = false
    var entry: ExplorationEntry = .compose
    var onSave: (_ discovery: Discovery, _ isNew: Bool) -> Void
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver
    @AppStorage("explorer-age") private var age = 7
    @State private var question = ""
    @State private var observation = ""
    @State private var record: ExplorationRecord?
    @State private var voice = VoiceSession()
    @State private var location = DiscoveryLocation()
    @State private var listening = false
    @State private var startingListening = false
    @State private var finishingListening = false
    @State private var voiceToken = UUID()
    @State private var voiceTask: Task<Void, Never>?
    @State private var dictation = DictationDraft(original: "")
    @State private var prepared = false
    @State private var recordingObservation = false
    @State private var speaking = false
    @State private var answerPresentation = AnswerPresentation()
    @State private var thinking = false
    @State private var error: String?
    @State private var questionError: AIClientError?
    @State private var questionStartedAt = Date()
    @State private var requestToken = UUID()
    @State private var photoDraft = PhotoDraft()
    private var photo: Data? { photoDraft.data }
    @State private var selection: PhotosPickerItem?
    @State private var photoPickerOpen = false
    @State private var cameraOpen = false
    @State private var replyTask: Task<Void, Never>?
    @FocusState private var focused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                if let record {
                    HStack { Spacer(minLength: 36); Text(record.question).padding(16).background(Color(hex: 0xDEF1FB), in: RoundedRectangle(cornerRadius: 22)) }
                    if let reply = record.reply {
                        answer(reply)
                        HStack(alignment: .top, spacing: 10) {
                            LeafBadge()
                            Text(reply.invitation).padding(16).frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.mint.opacity(0.75), in: RoundedRectangle(cornerRadius: 22))
                        }
                        if record.cardID == nil {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("What did you notice? (optional)").font(.system(.subheadline, design: .rounded, weight: .semibold))
                                TextField("I noticed…", text: $observation, axis: .vertical).lineLimit(2...4)
                                    .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18)).accessibilityIdentifier("observation-input")
                                    .disabled(thinking || listening || startingListening || finishingListening)
                                Button { toggleRecording(forObservation: true) } label: {
                                    Label(L10n.text(listening && recordingObservation ? "Finish recording" : "Say what you noticed"), systemImage: listening && recordingObservation ? "stop.fill" : "mic.fill")
                                }.frame(minHeight: 44).accessibilityIdentifier("observation-speak").disabled(finishingListening)
                                if let place = location.place {
                                    HStack { Label(place.name, systemImage: "location.fill"); Spacer(); Button("Remove") { location.remove() } }
                                } else {
                                    Button { location.request() } label: { Label(L10n.text(location.isLoading ? "Finding your place…" : "Add this place (optional)"), systemImage: "location") }
                                        .frame(minHeight: 44).disabled(location.isLoading)
                                }
                                if let error = location.error { Text(error).font(.caption).foregroundStyle(Theme.muted) }
                                Text("Your question is already a discovery. Keep it whenever you are ready.").font(.caption).foregroundStyle(Theme.muted)
                            }.padding(.leading, 48)
                        }
                        Button("Ask another question") {
                            answerPresentation.finish(); stopVoice(); self.record = nil; question = ""; observation = ""; photoDraft.clear(); selection = nil; error = nil; questionError = nil; location.remove(); focused = true
                        }.frame(minHeight: 44).frame(maxWidth: .infinity).accessibilityIdentifier("ask-another")
                    }
                } else if photoDraft.image == nil {
                    Image("explorer-hero").resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 26)).accessibilityHidden(true)
                    Text("Every discovery starts\nwith a question.").font(.system(.largeTitle, design: .rounded, weight: .black))
                    Text("Speak, type, or add a photo of something you notice.").foregroundStyle(Theme.muted)
                }
                if record?.reply == nil, let image = photoDraft.image {
                    Image(uiImage: image).resizable().scaledToFit().frame(maxHeight: 220).clipShape(RoundedRectangle(cornerRadius: 18)).accessibilityIdentifier("exploration-photo")
                    Button("Remove photo") { photoDraft.clear(); selection = nil }.frame(minHeight: 44)
                }
            }.padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(ExplorerBackdrop()).foregroundStyle(Theme.ink)
        .navigationTitle(record?.reply?.title ?? L10n.text("Let's explore")).navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                if thinking {
                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        HStack(spacing: 12) {
                            ProgressView().accessibilityIdentifier("thinking")
                            Text(L10n.text(timeline.date.timeIntervalSince(questionStartedAt) > 20 ? "Your guide is taking a little longer…" : "Your guide is thinking…"))
                                .font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
                            Button(action: pauseQuestion) { Text("Later").frame(minWidth: 44, minHeight: 44).contentShape(Rectangle()) }
                                .buttonStyle(.plain).accessibilityIdentifier("pause-question")
                        }.padding(.horizontal, 20).padding(.vertical, 8).background(Theme.paper)
                    }
                }
                if let error {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(error).font(.callout).accessibilityIdentifier("exploration-error")
                        if record?.reply == nil, !question.isEmpty, questionError?.allowsImmediateRetry != false {
                            Button(L10n.text(questionError == .pending || questionError == .timedOut ? "Check answer" : "Try again"), action: ask)
                                .frame(minHeight: 44).accessibilityIdentifier("retry-answer")
                        }
                    }.padding(14).frame(maxWidth: .infinity, alignment: .leading).background(Theme.sun.opacity(0.25), in: RoundedRectangle(cornerRadius: 18)).padding(.horizontal, 12)
                }
                if let record, record.reply != nil {
                VStack(spacing: 6) {
                    Button(action: keep) { Label(L10n.text(record.cardID == nil ? "Make my card" : "View my card"), systemImage: "sparkles") }
                        .buttonStyle(ExplorerButtonStyle()).accessibilityIdentifier("save-discovery")

                }.padding(.horizontal, 20).padding(.top, 12).background(Theme.paper)
                } else { composer }
            }
        }
        .onAppear(perform: prepare)
        .task(id: answerPresentation.generation) { [generation = answerPresentation.generation] in
            await answerPresentation.reveal(generation: generation)
        }
        .onDisappear { replyTask?.cancel(); photoDraft.cancel(); answerPresentation.finish(); stopVoice() }
        .onChange(of: reduceMotion) { _, enabled in if enabled { answerPresentation.finish() } }
        .onChange(of: voiceOver) { _, enabled in if enabled { answerPresentation.finish(); stopVoice() } }
        .onChange(of: scenePhase) { _, next in
            if next == .background {
                if thinking { pauseQuestion() }
                photoDraft.cancel(); answerPresentation.finish(); stopVoice()
            }
        }
        .onChange(of: selection) { _, item in
            if let item {
                focused = false
                photoPickerOpen = false
                photoDraft.load { try await item.loadTransferable(type: Data.self) }
                selection = nil
            }
        }
        .sheet(isPresented: $cameraOpen) {
            CameraCapture(onPhoto: { data in
                focused = false; selection = nil; photoDraft.load { data }; cameraOpen = false
            }, onCancel: { cameraOpen = false }).ignoresSafeArea()
        }
        .photosPicker(isPresented: $photoPickerOpen, selection: $selection, matching: .images)
    }

    private func answer(_ reply: AIReply) -> some View {
        HStack(alignment: .top, spacing: 10) {
            LeafBadge()
            VStack(alignment: .leading, spacing: 16) {
                (Text(answerPresentation.visibleText) + Text(answerPresentation.hiddenText).foregroundColor(.clear))
                    .font(.system(.body, design: .rounded)).textSelection(.enabled)
                    .accessibilityLabel(reply.answer).accessibilityIdentifier("live-answer")
                HStack(alignment: .top, spacing: 16) {
                    Button { if speaking { stopVoice() } else { speak(reply.answer) } } label: {
                        Label(L10n.text(speaking ? "Stop reply" : "Listen"), systemImage: speaking ? "stop.fill" : "speaker.wave.2.fill")
                            .frame(minHeight: 44).contentShape(Rectangle())
                    }.buttonStyle(.plain).accessibilityIdentifier("listen-answer")
                    Spacer(minLength: 0)
                    Button("Show full answer") { answerPresentation.finish() }
                        .font(.subheadline).frame(minHeight: 44).accessibilityIdentifier("show-full-answer")
                        .opacity(answerPresentation.isRevealing ? 1 : 0)
                        .disabled(!answerPresentation.isRevealing).accessibilityHidden(!answerPresentation.isRevealing)
                }
                if let image = photoDraft.image {
                    Image(uiImage: image).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 18)).accessibilityIdentifier("exploration-photo")
                }
                if photoDraft.isLoading { ProgressView("Preparing your photo…") }
                if photoDraft.error != nil {
                    Text("Your answer is saved. This photo couldn't be opened.").font(.caption).accessibilityIdentifier("photo-error")
                }
            }.padding(18).background(.white.opacity(0.97), in: RoundedRectangle(cornerRadius: 24))
                .shadow(color: Theme.ink.opacity(0.05), radius: 12, y: 3)
        }
    }

    private var composer: some View {
        VStack(spacing: 10) {
            if photoDraft.isLoading {
                HStack {
                    ProgressView()
                    Text("Preparing your photo…").font(.caption)
                    Spacer()
                    Button("Cancel photo") { photoDraft.cancel(); selection = nil }.frame(minHeight: 44)
                }.padding(.horizontal, 16).accessibilityIdentifier("preparing-photo")
            }
            if let message = photoDraft.error {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message).accessibilityIdentifier("photo-error")
                    if photoDraft.image != nil { Text("Your previous photo is still attached.") }
                    else if record?.photoFilename != nil, !photoDraft.hasChanges {
                        Button("Remove photo") { photoDraft.clear(); selection = nil }.frame(minHeight: 44)
                    }
                }.font(.caption).padding(.horizontal, 16)
            }
            if listening || startingListening || finishingListening {
                Text(L10n.text(startingListening ? "Getting the microphone ready…" : finishingListening ? "Keeping your last words…" : "I'm listening…"))
                    .font(.caption).accessibilityIdentifier("exploration-status")
            }
            TextField("Ask anything…", text: $question, axis: .vertical).lineLimit(1...4).focused($focused)
                .padding(.horizontal, 16).padding(.top, 12).accessibilityIdentifier("exploration-input")
                .disabled(thinking || listening || startingListening || finishingListening)
            HStack(spacing: 18) {
                Button { focused = false; photoPickerOpen = true } label: { Image(systemName: "photo").frame(width: 44, height: 44) }
                    .accessibilityLabel("Choose a photo").disabled(thinking || listening || startingListening || finishingListening)
                Button(action: openCamera) { Image(systemName: "camera").frame(width: 44, height: 44) }.accessibilityLabel("Take a photo").disabled(thinking || photoDraft.isLoading || listening || startingListening || finishingListening)
                Spacer()
                Button { toggleRecording() } label: { Image(systemName: listening ? "stop.fill" : "mic.fill").frame(width: 44, height: 44).background(Theme.mint, in: Circle()) }
                    .accessibilityLabel(L10n.text(listening || startingListening ? "Finish recording" : "Speak your question"))
                    .accessibilityIdentifier("speak-button").disabled(thinking || finishingListening)
                Button(action: ask) { Image(systemName: "arrow.up").font(.title3.bold()).foregroundStyle(.white).frame(width: 44, height: 44).background(Theme.forest, in: Circle()) }
                    .accessibilityLabel("Send question").accessibilityIdentifier("ask-button")
                    .disabled(thinking || photoDraft.isLoading || startingListening || finishingListening || question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }.padding(.horizontal, 8)
            if photo != nil { Text("This photo will be sent to your AI guide with your question.").font(.caption2).foregroundStyle(Theme.muted).padding(.horizontal) }
        }.padding(.bottom, 10).background(.white, in: RoundedRectangle(cornerRadius: 26))
            .shadow(color: Theme.ink.opacity(0.08), radius: 12, y: -2).padding(.horizontal, 12).padding(.bottom, 6)
    }

    private func prepare() {
        guard !prepared else { return }
        prepared = true
        voice.onTranscript = { if recordingObservation { observation = dictation.applying($0) } else { question = dictation.applying($0) } }
        voice.onError = { error = $0; speaking = false; listening = false; startingListening = false; finishingListening = false }
        voice.onInterrupted = { listening = false; startingListening = false; finishingListening = false; speaking = false }
        voice.onFinishedSpeaking = { speaking = false }
        voice.onFinishedListening = { listening = false; startingListening = false }
        if let recordID, let existing = store.questions.first(where: { $0.id == recordID }) {
            record = existing; question = existing.question
            if let filename = existing.photoFilename {
                let url = store.mediaURL(filename)
                photoDraft.load(preservingData: true) { try Data(contentsOf: url) }
            }
            if existing.reply == nil {
                questionError = .pending
                error = L10n.text("Your question is saved. Check the answer whenever you're ready.")
            } else if let reply = existing.reply {
                present(reply, animated: presentAnswerOnOpen)
            }
            return
        }
        if question.isEmpty { question = initialQuestion }
        switch entry {
        case .compose: focused = true
        case .voice: toggleRecording()
        case .camera: openCamera()
        case .question: ask()
        }
    }

    private func ask() {
        guard !thinking, !photoDraft.isLoading, !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if listening { finishRecording(then: ask); return }
        guard !startingListening, !finishingListening else { return }
        let previousID = record?.id
        let readSavedAnswer = questionError != .answerFailed
        focused = false; stopVoice(); error = nil; questionError = nil
        do {
            if record?.question != question.trimmingCharacters(in: .whitespacesAndNewlines) || photoDraft.hasChanges {
                record = try store.beginQuestion(question, age: age, photo: photo)
                photoDraft.markSaved()
                observation = ""
            }
            guard let record else { return }
            if let reply = record.reply { present(reply, animated: true); return }
            thinking = true
            questionStartedAt = Date()
            let token = UUID(); requestToken = token
            let requestPhoto = photo
            replyTask = Task { @MainActor in
                defer { if requestToken == token { thinking = false } }
                do {
                    let connection = try ConnectionVault().loadOrCreate()
                    let client = AIClient()
                    let receipt = try await client.answer(record, photo: requestPhoto, connection: connection, resume: previousID == record.id && readSavedAnswer)
                    try Task.checkCancellation()
                    guard requestToken == token, let reply = receipt.reply else { throw AIClientError.invalidResponse }
                    try store.saveAnswer(reply, for: record.id)
                    self.record = store.questions.first { $0.id == record.id }
                    present(reply, animated: true)
                } catch is CancellationError {}
                catch {
                    if !Task.isCancelled, requestToken == token {
                        questionError = error as? AIClientError
                        self.error = questionError?.localizedDescription ?? journalMessage(error)
                    }
                }
            }
        } catch { self.error = journalMessage(error) }
    }

    private func pauseQuestion() {
        replyTask?.cancel(); requestToken = UUID(); thinking = false
        questionError = .pending
        error = L10n.text("Your question is saved. Check the answer whenever you're ready.")
    }

    private func keep() {
        guard let record else { return }
        if listening { finishRecording(then: keep); return }
        guard !startingListening, !finishingListening else { return }
        stopVoice()
        do {
            let isNew = record.cardID == nil
            let image = record.preparedContent.flatMap { PreparedAssets().cached($0.artwork, bundled: $0.bundledArtwork) }
            let card = try store.keepQuestion(record.id, observation: observation, tripID: tripID, place: location.place, preparedImage: image)
            self.record = store.questions.first { $0.id == record.id } ?? record
            onSave(card, isNew)
        }
        catch { self.error = journalMessage(error) }
    }

    private func speak(_ text: String) {
        stopVoice()
        do {
            let saved = record
            try voice.speak(text, language: saved?.language ?? AppLanguage.current.rawValue, cloud: {
                guard let saved else { throw VoiceError.unavailable }
                let connection = try ConnectionVault().loadOrCreate()
                return try await NarrationClient().audio(for: saved, connection: connection)
            })
            speaking = true
        }
        catch { speaking = false; self.error = L10n.text("The voice isn't available right now. You can read the answer or listen again later.") }
    }

    private func present(_ reply: AIReply, animated: Bool) {
        answerPresentation.begin(reply.answer, animated: animated && !reduceMotion && !voiceOver)
        if animated && !voiceOver { speak(reply.answer) }
    }

    private func toggleRecording(forObservation: Bool = false) {
        if startingListening { stopVoice(); return }
        if listening { finishRecording(); return }
        guard !finishingListening else { return }
        focused = false; stopVoice(); error = nil; startingListening = true; recordingObservation = forObservation
        dictation = DictationDraft(original: forObservation ? observation : question)
        let token = UUID(); voiceToken = token
        voiceTask = Task {
            do {
                try await voice.start(language: forObservation ? record?.language ?? AppLanguage.current.rawValue : AppLanguage.current.rawValue)
                guard voiceToken == token else { return }
                startingListening = false; listening = true
            } catch {
                guard voiceToken == token else { return }
                stopVoice()
                if !(error is CancellationError) { self.error = (error as? VoiceError)?.localizedDescription ?? VoiceError.unavailable.localizedDescription }
            }
        }
    }

    private func finishRecording(then action: (() -> Void)? = nil) {
        guard !finishingListening else { return }
        finishingListening = true; listening = false
        let token = voiceToken
        voiceTask = Task {
            await voice.finish()
            guard voiceToken == token, !Task.isCancelled else { return }
            finishingListening = false
            action?()
        }
    }

    private func stopVoice() {
        voiceTask?.cancel(); voiceToken = UUID(); voice.stop()
        listening = false; startingListening = false; finishingListening = false; speaking = false
    }

    private func journalMessage(_ error: Error) -> String {
        if let error = error as? JournalError { return error.localizedDescription }
        return L10n.text("Your phone couldn't save this yet. Your words are still on this screen. Please try again.")
    }

    private func openCamera() {
        stopVoice()
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            error = L10n.text("A camera is available when you explore on an iPhone. You can still keep a voice discovery here.")
            return
        }
        Task {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            let allowed = status == .notDetermined ? await AVCaptureDevice.requestAccess(for: .video) : status == .authorized
            if allowed { cameraOpen = true }
            else { error = L10n.text("Camera access is off. Enable it in Settings. Voice exploration still works.") }
        }
    }
}
