import Foundation

struct PageResult<T: Codable>: Codable {
    let totalCount: Int
    let page: Int
    let pageSize: Int
    let totalPages: Int
    let items: [T]
}
