import Foundation

struct AppleMusicSearchResponse: Decodable {
    let results: SearchResults
}
struct SearchResults: Decodable {
    let songs: SongCollection?
}
struct SongCollection: Decodable {
    let data: [SongData]
}
struct SongData: Decodable {
    let id: String
    let attributes: SongAttributes
}
struct SongAttributes: Decodable {
    let name: String
    let artistName: String
}
