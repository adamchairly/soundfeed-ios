import SwiftUI

struct FeedView: View {
    var viewModel: FeedViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.isLoading && viewModel.releases.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = viewModel.error, viewModel.releases.isEmpty {
                    ContentUnavailableView {
                        Label("Failed to load releases", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Retry") {
                            Task { await viewModel.loadReleases() }
                        }
                    }
                } else if viewModel.releases.isEmpty {
                    Text("No new releases. You are up to date!")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .containerRelativeFrame(.vertical)
                } else {
                    ForEach(viewModel.groupedByMonth, id: \.key) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(group.label)
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            ForEach(group.releases) { release in
                                ReleaseCardView(release: release) {
                                    Task { await viewModel.dismissRelease(id: release.id) }
                                }
                            }
                        }
                        .padding(.top, 18)
                    }

                    if viewModel.hasMore {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .onAppear {
                                Task { await viewModel.loadMore() }
                            }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await viewModel.loadReleases()
        }
    }
}

#Preview {
    FeedView(viewModel: FeedViewModel())
}
