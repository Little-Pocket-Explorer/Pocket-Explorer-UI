import AVFoundation
import SwiftUI

struct ExploreView: View {
    let store: TripStore
    let tripID: UUID?
    var onSave: (Discovery) -> Void
    @Environment(\.scenePhase) private var scenePhase
    @State private var session = ExplorationState()
    @State private var voice = VoiceSession()
    @State private var photo: Data?
    @State private var cameraOpen = false
    @State private var submitting = false
    @State private var savedID = UUID()
    @State private var createdTripID: UUID?
    @State private var replyTask: Task<Void, Never>?
    @FocusState private var inputFocused: Bool

    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Eyebrow(text: session.stage == .question ? "1 · Ask" : "2 · Look closer")
                            Text(L10n.text(session.stage == .question ? "What are you curious about?" : "What did you notice?"))
                                .font(.system(.title, design: .rounded, weight: .heavy))
                        }
                        Image((session.reply?.subject ?? .duck).rawValue)
                            .resizable().scaledToFit().frame(width: 108)
                            .clipShape(RoundedRectangle(cornerRadius: 24)).accessibilityHidden(true)
                    }.id("step")
                    if let reply = session.reply {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(session.question).font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(Theme.muted)
                            Text(reply.answer).font(.system(.body, design: .rounded, weight: .semibold))
                            Divider()
                            Text(reply.invitation).font(.body)
                        }
                        .padding(20).background(Theme.surface, in: RoundedRectangle(cornerRadius: 24))
                    } else {
                        Text("Try a sample question, or ask your own.").font(.subheadline).foregroundStyle(Theme.muted)
                        HStack(spacing: 10) {
                            ForEach(DiscoverySubject.allCases) { subject in
                                Button {
                                    session.question = subject.sampleQuestion
                                    ask()
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(subject.rawValue).resizable().scaledToFit().frame(height: 48).accessibilityHidden(true)
                                        Text(L10n.text(subject.rawValue.capitalized)).font(.system(.caption, design: .rounded, weight: .bold))
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 80)
                                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(L10n.text("Try a sample question") + ": " + subject.sampleQuestion)
                                .accessibilityIdentifier("sample-\(subject.rawValue)")
                                .disabled(session.phase == .listening || session.phase == .thinking)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.text(session.stage == .question ? "Your question · speak or type" : "Your observation · speak or type"))
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                        TextField(L10n.text(session.stage == .question ? "What would you like to explore?" : "I noticed…"), text: transcript, axis: .vertical)
                            .lineLimit(2...4).focused($inputFocused)
                            .padding(15).background(.white, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.line))
                            .accessibilityIdentifier("exploration-input")
                        if session.stage == .observation {
                            Text("Your own words will appear on your card.").font(.caption).foregroundStyle(Theme.muted)
                        }
                    }
                    if let error = session.error {
                        Text(error).font(.callout).padding(14)
                            .background(Theme.sun.opacity(0.25), in: RoundedRectangle(cornerRadius: 14))
                            .accessibilityIdentifier("exploration-error")
                    }
                    Button(action: openCamera) {
                        Label(L10n.text(photo == nil ? "Add a photo (optional)" : "Retake my photo"), systemImage: "camera")
                    }.frame(minHeight: 44)
                    if let photo, let image = UIImage(data: photo) {
                        Image(uiImage: image).resizable().scaledToFit().frame(maxHeight: 160).clipShape(RoundedRectangle(cornerRadius: 14))
                        Button("Remove photo") { self.photo = nil }.frame(minHeight: 44)
                    }
                    Text("Prepared demo: ducks, leaves and shells. Photos stay in your journal.")
                        .font(.caption).foregroundStyle(Theme.muted)
                }.padding(24)
            }
            .onChange(of: session.stage) { _, _ in reader.scrollTo("step", anchor: .top) }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 8) {
                Text(L10n.text(statusText)).font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(Theme.muted).accessibilityIdentifier("exploration-status")
                Button(action: performPrimaryAction) {
                    Label(L10n.text(primaryTitle), systemImage: primaryIcon)
                }
                .buttonStyle(ExplorerButtonStyle())
                .accessibilityIdentifier(primaryIdentifier)
                .disabled(session.primaryAction == .wait || submitting)
                if session.primaryAction == .ask || session.primaryAction == .save {
                    Button(action: toggleRecording) { Label("Record again", systemImage: "mic") }
                        .frame(minHeight: 44).accessibilityIdentifier("speak-button")
                }
                if session.phase == .thinking {
                    Button("Cancel") { replyTask?.cancel(); session.stop() }.frame(minHeight: 44)
                }
            }
            .padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 8)
            .frame(maxWidth: .infinity).background(Theme.paper)
        }
        .background(Theme.paper).foregroundStyle(Theme.ink)
        .navigationTitle("Let's explore").navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: connectVoice)
        .onDisappear { replyTask?.cancel(); voice.stop() }
        .onChange(of: scenePhase) { _, next in
            if next != .active { replyTask?.cancel(); voice.stop(); session.stop() }
        }
        .sheet(isPresented: $cameraOpen) {
            CameraCapture(onPhoto: { photo = $0; cameraOpen = false }, onCancel: { cameraOpen = false }).ignoresSafeArea()
        }
    }

    private var primaryTitle: String {
        switch session.primaryAction {
        case .record: return session.stage == .question ? "Tap to ask" : "Tell me what you noticed"
        case .finishQuestion: return "Done · hear the answer"
        case .finishObservation: return "Done · check my words"
        case .ask: return "Hear the answer"
        case .save: return "Make my card"
        case .stopReply: return "I'm ready to look closer"
        case .wait: return "Thinking…"
        }
    }
    private var primaryIcon: String {
        switch session.primaryAction {
        case .record: return "mic.fill"
        case .finishQuestion, .finishObservation: return "stop.fill"
        case .ask: return "arrow.up"
        case .save: return "sparkles"
        case .stopReply: return "arrow.right"
        case .wait: return "ellipsis"
        }
    }
    private var primaryIdentifier: String {
        switch session.primaryAction {
        case .record, .finishQuestion, .finishObservation: return "speak-button"
        case .ask: return "ask-button"
        case .save: return "save-discovery"
        case .stopReply: return "stop-reply"
        case .wait: return "thinking"
        }
    }
    private func performPrimaryAction() {
        inputFocused = false
        switch session.primaryAction {
        case .record: toggleRecording()
        case .finishQuestion:
            voice.stop(); session.stop()
            if !session.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { ask() }
        case .finishObservation: voice.stop(); session.stop()
        case .ask: ask()
        case .save: save()
        case .stopReply: voice.stop(); session.beginObservation()
        case .wait: break
        }
    }

    private var transcript: Binding<String> {
        Binding(get: { session.stage == .question ? session.question : session.observation }, set: { session.receiveTranscript($0) })
    }
    private var statusText: String {
        switch session.phase {
        case .listening: return "I'm listening…"
        case .thinking: return "A little moment to think…"
        case .speaking: return "Let's look a little closer"
        case .failed: return "Your words are still here"
        case .idle: return session.stage == .question ? "Tap below to speak, or try a sample above." : "Notice one thing, then make it into your card."
        }
    }
    private func connectVoice() {
        voice.onTranscript = { session.receiveTranscript($0) }
        voice.onError = { session.fail($0) }
        voice.onFinishedSpeaking = { session.beginObservation() }
        voice.onInterrupted = { session.stop() }
    }
    private func toggleRecording() {
        if session.phase == .listening { voice.stop(); session.stop(); return }
        inputFocused = false
        voice.stop()
        session.startListening()
        Task {
            do { try await voice.start() }
            catch is CancellationError {}
            catch { voice.stop(); session.fail(error.localizedDescription) }
        }
    }
    private func ask() {
        inputFocused = false
        voice.stop()
        replyTask?.cancel()
        session.think()
        replyTask = Task { @MainActor in
            do { try await Task.sleep(for: .milliseconds(350)) } catch { return }
            guard !Task.isCancelled else { return }
            session.answer()
            guard let reply = session.reply, session.phase == .speaking else { return }
            do { try voice.speak(reply.answer + " " + reply.invitation) }
            catch { session.fail(error.localizedDescription); session.beginObservation() }
        }
    }
    private func save() {
        guard session.canSave, let reply = session.reply, !submitting else { return }
        submitting = true
        voice.stop()
        do {
            let target: UUID
            if let existing = tripID ?? createdTripID { target = existing }
            else {
                target = try store.createTrip(title: L10n.text("A day of little wonders"), place: nil)
                createdTripID = target
            }
            let record = try store.addDiscovery(tripID: target, subject: reply.subject, question: session.question, observation: session.observation, explanation: reply.answer, photo: photo, id: savedID)
            onSave(record)
        } catch { submitting = false; session.fail(error.localizedDescription) }
    }
    private func openCamera() {
        voice.stop(); session.stop()
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            session.fail(L10n.text("A camera is available when you explore on an iPhone. You can still keep a voice discovery here."))
            return
        }
        Task {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            let allowed: Bool
            if status == .notDetermined { allowed = await AVCaptureDevice.requestAccess(for: .video) }
            else { allowed = status == .authorized }
            if allowed { cameraOpen = true }
            else { session.fail(L10n.text("Camera access is off. Enable it in Settings. Voice exploration still works.")) }
        }
    }
}
