import Foundation

struct ClockStatus: Codable, Equatable {
    var minutes: Int = 0
    var seconds: Int = 0
    var currentRound: Int = 0
    var totalRounds: Int = 0
    var isRunning: Bool = false
    var isPaused: Bool = false
    var elapsedMinutes: Int = 0
    var elapsedSeconds: Int = 0
    var isBetweenRounds: Bool = false
    var betweenRoundsMinutes: Int = 0
    var betweenRoundsSeconds: Int = 0
    var betweenRoundsEnabled: Bool = false
    var betweenRoundsTime: Int = 0
    var warningLeadTime: Int = 0
    var warningSoundPath: String?
    var endSoundPath: String?
    var ntpSyncEnabled: Bool = false
    var ntpOffset: Int = 0
    var endTime: String?
    var timeStamp: String?
    // Extras returned by /status
    var serverTime: Int?
    var apiVersion: String?
    var connectionProtocol: String?

    private var hasDecodedStatusKeys: Bool?

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

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        hasDecodedStatusKeys = !container.allKeys.isEmpty

        minutes = try container.decodeIfPresent(Int.self, forKey: .minutes) ?? 0
        seconds = try container.decodeIfPresent(Int.self, forKey: .seconds) ?? 0
        currentRound = try container.decodeIfPresent(Int.self, forKey: .currentRound) ?? 0
        totalRounds = try container.decodeIfPresent(Int.self, forKey: .totalRounds) ?? 0
        isRunning = try container.decodeIfPresent(Bool.self, forKey: .isRunning) ?? false
        isPaused = try container.decodeIfPresent(Bool.self, forKey: .isPaused) ?? false
        elapsedMinutes = try container.decodeIfPresent(Int.self, forKey: .elapsedMinutes) ?? 0
        elapsedSeconds = try container.decodeIfPresent(Int.self, forKey: .elapsedSeconds) ?? 0
        isBetweenRounds = try container.decodeIfPresent(Bool.self, forKey: .isBetweenRounds) ?? false
        betweenRoundsMinutes = try container.decodeIfPresent(Int.self, forKey: .betweenRoundsMinutes) ?? 0
        betweenRoundsSeconds = try container.decodeIfPresent(Int.self, forKey: .betweenRoundsSeconds) ?? 0
        betweenRoundsEnabled = try container.decodeIfPresent(Bool.self, forKey: .betweenRoundsEnabled) ?? false
        betweenRoundsTime = try container.decodeIfPresent(Int.self, forKey: .betweenRoundsTime) ?? 0
        warningLeadTime = try container.decodeIfPresent(Int.self, forKey: .warningLeadTime) ?? 0
        warningSoundPath = try container.decodeIfPresent(String.self, forKey: .warningSoundPath)
        endSoundPath = try container.decodeIfPresent(String.self, forKey: .endSoundPath)
        ntpSyncEnabled = try container.decodeIfPresent(Bool.self, forKey: .ntpSyncEnabled) ?? false
        ntpOffset = try container.decodeIfPresent(Int.self, forKey: .ntpOffset) ?? 0
        endTime = try container.decodeIfPresent(String.self, forKey: .endTime)
        timeStamp = try container.decodeIfPresent(String.self, forKey: .timeStamp)
        serverTime = try container.decodeIfPresent(Int.self, forKey: .serverTime)
        apiVersion = try container.decodeIfPresent(String.self, forKey: .apiVersion)
        connectionProtocol = try container.decodeIfPresent(String.self, forKey: .connectionProtocol)
    }
}

extension ClockStatus {
    /// Returns `true` when at least one property differs from the default `ClockStatus` value.
    var hasAnyStatusFields: Bool {
        if let hasDecodedStatusKeys {
            return hasDecodedStatusKeys
        }

        return self != ClockStatus()
    }
}

extension ClockStatus {
    static func == (lhs: ClockStatus, rhs: ClockStatus) -> Bool {
        lhs.minutes == rhs.minutes &&
        lhs.seconds == rhs.seconds &&
        lhs.currentRound == rhs.currentRound &&
        lhs.totalRounds == rhs.totalRounds &&
        lhs.isRunning == rhs.isRunning &&
        lhs.isPaused == rhs.isPaused &&
        lhs.elapsedMinutes == rhs.elapsedMinutes &&
        lhs.elapsedSeconds == rhs.elapsedSeconds &&
        lhs.isBetweenRounds == rhs.isBetweenRounds &&
        lhs.betweenRoundsMinutes == rhs.betweenRoundsMinutes &&
        lhs.betweenRoundsSeconds == rhs.betweenRoundsSeconds &&
        lhs.betweenRoundsEnabled == rhs.betweenRoundsEnabled &&
        lhs.betweenRoundsTime == rhs.betweenRoundsTime &&
        lhs.warningLeadTime == rhs.warningLeadTime &&
        lhs.warningSoundPath == rhs.warningSoundPath &&
        lhs.endSoundPath == rhs.endSoundPath &&
        lhs.ntpSyncEnabled == rhs.ntpSyncEnabled &&
        lhs.ntpOffset == rhs.ntpOffset &&
        lhs.endTime == rhs.endTime &&
        lhs.timeStamp == rhs.timeStamp &&
        lhs.serverTime == rhs.serverTime &&
        lhs.apiVersion == rhs.apiVersion &&
        lhs.connectionProtocol == rhs.connectionProtocol
    }
}
