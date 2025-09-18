import Foundation

struct ClockStatus: Codable {
    var minutes: Int
    var seconds: Int
    var currentRound: Int
    var totalRounds: Int
    var isRunning: Bool
    var isPaused: Bool
    var elapsedMinutes: Int
    var elapsedSeconds: Int
    var isBetweenRounds: Bool
    var betweenRoundsMinutes: Int
    var betweenRoundsSeconds: Int
    var betweenRoundsEnabled: Bool
    var betweenRoundsTime: Int
    var warningLeadTime: Int
    var warningSoundPath: String?
    var endSoundPath: String?
    var ntpSyncEnabled: Bool
    var ntpOffset: Int
    var endTime: String?
    var timeStamp: String?
    // Extras returned by /status
    var serverTime: Int?
    var apiVersion: String?
    var connectionProtocol: String?

    enum CodingKeys: String, CodingKey {
        case minutes
        case seconds
        case currentRound
        case totalRounds
        case isRunning
        case isPaused
        case elapsedMinutes
        case elapsedSeconds
        case isBetweenRounds
        case betweenRoundsMinutes
        case betweenRoundsSeconds
        case betweenRoundsEnabled
        case betweenRoundsTime
        case warningLeadTime
        case warningSoundPath
        case endSoundPath
        case ntpSyncEnabled
        case ntpOffset
        case endTime
        case timeStamp
        case serverTime
        case apiVersion = "api_version"
        case connectionProtocol = "connection_protocol"
    }
}
