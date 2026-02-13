import SwiftUI

struct RootView: View {
    @State private var selectedTab: AppTab = .feed
    @State private var feedViewModel = FeedViewModel()
    @State private var settingsViewModel = SettingsViewModel()
    @State private var addArtistViewModel = AddArtistViewModel()
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                SplashView()
            } else {
                TabView(selection: $selectedTab) {
                    Tab("Feed", systemImage: "list.dash", value: .feed) {
                        FeedView(viewModel: feedViewModel)
                            .withAppHeader()
                    }

                    Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                        SettingsView(viewModel: settingsViewModel)
                            .withAppHeader()
                    }

                    Tab("Add", systemImage: "plus", value: .addArtist, role: .search) {
                        AddArtistView(viewModel: addArtistViewModel)
                            .withAppHeader()
                    }
                }
                .tabBarMinimizeBehavior(.onScrollDown)
            }
        }
        .task {
            await loadInitialData()
        }
    }
    
    private func loadInitialData() async {
        async let releases: () = feedViewModel.loadReleases()
        async let user: () = settingsViewModel.loadUser()
        async let sync: () = settingsViewModel.loadSync()
        async let artists: () = addArtistViewModel.loadArtists()

        await releases
        await user
        await sync
        await artists
        
        isLoading = false
    }
}

#Preview {
    RootView()
}
