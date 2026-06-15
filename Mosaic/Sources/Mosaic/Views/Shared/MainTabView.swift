import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DiscoveryGridView()
                .tabItem {
                    Label("Discover", systemImage: "squareshape.split.3x3")
                }

            ConversationsView()
                .tabItem {
                    Label("Messages", systemImage: "message")
                }

            OwnProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .tint(Color.mosaicAccent)
    }
}
