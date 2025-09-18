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
    var api_version: String?
    var connection_protocol: String?
}