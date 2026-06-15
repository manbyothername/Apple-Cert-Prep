import SwiftUI

struct DiscoveryGridView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = DiscoveryViewModel()
    @StateObject private var blockViewModel = BlockViewModel()

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    private let adEveryNRows = 5 // insert an ad banner every 5 rows (= every 15 user tiles)

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mosaicBackground.ignoresSafeArea()

                if viewModel.isLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(Array(viewModel.users.enumerated()), id: \.element.uid) { index, user in
                                if index > 0 && index % (adEveryNRows * 3) == 0 {
                                    AdTileView()
                                        .gridCellColumns(3)
                                }
                                NavigationLink {
                                    ProfileView(user: user, blockViewModel: blockViewModel)
                                } label: {
                                    UserTileView(user: user)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .refreshable {
                        guard let uid = authViewModel.currentUser?.uid else { return }
                        await viewModel.load(currentUserId: uid)
                    }
                }
            }
            .navigationTitle("Mosaic")
            .task {
                guard let uid = authViewModel.currentUser?.uid else { return }
                await viewModel.load(currentUserId: uid)
            }
            .sheet(isPresented: $blockViewModel.showReasonPicker) {
                BlockReasonPickerView(
                    viewModel: blockViewModel,
                    currentUserId: authViewModel.currentUser?.uid ?? "",
                    onBlocked: {
                        Task {
                            guard let uid = authViewModel.currentUser?.uid else { return }
                            await viewModel.load(currentUserId: uid)
                        }
                    }
                )
            }
        }
    }
}
