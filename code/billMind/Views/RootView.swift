import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        ContentView()
            .onOpenURL { url in
                DeepLinkHandler.handle(url, context: context)
            }
    }
}
