import SwiftUI

struct ReleaseCardView: View {
    let release: Release
    var onDismiss: (() -> Void)?

    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            coverImage

            VStack(alignment: .leading, spacing: 4) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(release.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)

                    Text(release.artistName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                metadataRow
            }

            Spacer()

            Button {
                onDismiss?()
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            if let urlString = release.spotifyUrl, let url = URL(string: urlString) {
                openURL(url)
            }
        }
    }

    @ViewBuilder
    private var coverImage: some View {
        if let urlString = release.coverUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    coverPlaceholder
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        } else {
            coverPlaceholder
        }
    }
    
    private var coverPlaceholder: some View {
        RoundedRectangle(cornerRadius: 6)
            .frame(width: 56, height: 56)
            .overlay {
                Image(systemName: "music.note")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
            }
    }

    private var metadataRow: some View {
        HStack(spacing: 4) {
            
            // release type
            if let type = release.releaseType {
                Text(type.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.3)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 3))
            }
            
            // date
            Spacer(minLength: 1)
            Text(release.formattedDate)
                .font(.caption2)
                .foregroundStyle(.gray)
            
            // label
            Spacer(minLength: 1)
            if let label = release.label {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
        }
    }
}

