import Foundation

@Observable
final class FeedViewModel {

    private let releaseService = ReleaseService()

    var releases: [Release] = []
    var isLoading = false
    var error: String?

    private var currentPage = 1
    private var totalPages = 1
    private let pageSize = 20
    var hasMore: Bool { currentPage < totalPages }

    var groupedByMonth: [(key: String, label: String, releases: [Release])] {
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

    func loadReleases() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        do {
            let result = try await releaseService.fetchReleases(page: 1, pageSize: pageSize)
            releases = result.items
            currentPage = result.page
            totalPages = result.totalPages
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func loadMore() async {
        guard !isLoading, hasMore else { return }
        isLoading = true

        do {
            let result = try await releaseService.fetchReleases(page: currentPage + 1, pageSize: pageSize)
            releases.append(contentsOf: result.items)
            currentPage = result.page
            totalPages = result.totalPages
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func dismissRelease(id: Int) async {

        releases.removeAll { $0.id == id }

        do {
            try await releaseService.dismissRelease(id: id)
        } catch {
            // Reload on failure to restore state
            await loadReleases()
        }
    }
}
