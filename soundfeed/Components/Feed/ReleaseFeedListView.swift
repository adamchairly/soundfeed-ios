import SwiftUI

struct ReleaseFeedListView: View {
    let releases: [Release]

    private var groupedByMonth: [(key: String, label: String, releases: [Release])] {
        let sorted = releases.sorted { $0.releaseDate > $1.releaseDate }

        var result: [(key: String, label: String, releases: [Release])] = []
        var currentKey = ""
        var currentGroup: [Release] = []
        var currentLabel = ""

        for release in sorted {
            let key = release.monthYearKey
            if key != currentKey {
                if !currentGroup.isEmpty {
                    result.append((key: currentKey, label: currentLabel, releases: currentGroup))
                }
                currentKey = key
                currentLabel = release.monthYearLabel
                currentGroup = [release]
            } else {
                currentGroup.append(release)
            }
        }

        if !currentGroup.isEmpty {
            result.append((key: currentKey, label: currentLabel, releases: currentGroup))
        }

        return result
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(groupedByMonth, id: \.key) { group in
                    Section {
                        ForEach(group.releases) { release in
                            ReleaseCardView(release: release)
                        }
                    } header: {
                        MonthSectionHeaderView(title: group.label)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
        .background(Color(.systemGroupedBackground))
    }
}
