import SwiftUI

struct AddArtistView: View {
    @Bindable var viewModel: AddArtistViewModel
    @Environment(\.colorScheme) private var colorScheme

    private var buttonTint: Color {
        colorScheme == .dark ? Color(.systemGray3) : Color(.darkGray)
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                sectionGroup(header: "Search") {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField("Search artists...", text: $viewModel.searchQuery)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        if viewModel.isSearching {
                            ProgressView()
                        } else if !viewModel.searchQuery.isEmpty {
                            Button {
                                viewModel.searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                if !viewModel.searchResults.isEmpty {
                    sectionGroup(header: "Results") {
                        VStack(spacing: 0) {
                            ForEach(viewModel.searchResults) { result in
                                HStack(spacing: 12) {
                                    artistImage(url: result.imageUrl, size: 44)

                                    Text(result.name)
                                        .lineLimit(1)

                                    Spacer()

                                    if let spotifyUrl = result.spotifyUrl {
                                        Button {
                                            Task { await viewModel.addArtist(spotifyUrl: spotifyUrl) }
                                        } label: {
                                            Image(systemName: "plus")
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(buttonTint)
                                        .buttonBorderShape(.circle)
                                    }
                                }
                                .padding(.vertical, 6)

                                if result.id != viewModel.searchResults.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                }

                if viewModel.isLoading && viewModel.artists.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 32)
                } else if viewModel.artists.isEmpty {
                    Text("You did not add any artist yet.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .containerRelativeFrame(.vertical)
                } else {
                    sectionGroup(header: "Your Artists", footer: "These are the artists that you follow. The system checks their new releases, and shows them to you.") {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.artists) { artist in
                                artistCell(artist)
                            }
                        }
                    }
                }

                if let error = viewModel.error {
                    sectionGroup {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }

                if let success = viewModel.successMessage {
                    sectionGroup {
                        Label(success, systemImage: "checkmark.circle")
                            .foregroundStyle(.green)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await viewModel.loadArtists()
        }
    }

    private func artistCell(_ artist: Artist) -> some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                artistImage(url: artist.imageUrl, size: 56)

                Button {
                    Task { await viewModel.removeArtist(id: artist.id) }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 18, height: 18)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
                }
                .offset(x: 4, y: -4)
            }

            Text(artist.name)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    private func artistImage(url: String?, size: CGFloat) -> some View {
        Group {
            if let url, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color(.systemGray5)
                }
            } else {
                Color(.systemGray5)
                    .overlay {
                        Image(systemName: "music.mic")
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func sectionGroup<Content: View>(header: String? = nil, footer: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let header {
                Text(header)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            content()
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            if let footer {
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.top, 18)
    }
}

#Preview {
    AddArtistView(viewModel: AddArtistViewModel())
}
