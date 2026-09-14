import SwiftUI

struct CachedMediaImage<Placeholder: View>: View {
    let url: URL
    var contentMode: ContentMode = .fill
    @ViewBuilder var placeholder: () -> Placeholder
    @State private var image: UIImage?
    @State private var loadedURL: URL?
    @State private var failed = false

    var body: some View {
        Group {
            if loadedURL == url, let image {
                Image(uiImage: image).resizable().aspectRatio(contentMode: contentMode)
            } else if loadedURL == url, failed {
                VStack(spacing: 10) {
                    Image(systemName: "photo").font(.largeTitle)
                    Text("Picture unavailable").font(.caption).multilineTextAlignment(.center)
                }.foregroundStyle(Theme.muted).frame(maxWidth: .infinity, minHeight: 120).padding()
            } else { placeholder() }
        }.task(id: url) {
            let result = await MediaImageCache.shared.image(at: url)
            guard !Task.isCancelled else { return }
            image = result; loadedURL = url; failed = result == nil
        }
    }
}
