import Foundation

struct WSMessage: Codable {
    let type: String
    let status: ClockStatus?
}