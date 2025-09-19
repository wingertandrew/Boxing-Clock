import Foundation

// A new struct to handle nested time objects from the server
struct TimeValue: Codable, Equatable {
    var minutes: Int
    var seconds: Int
}

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
    var timeStamp: TimeInterval? // Changed to TimeInterval for direct numeric parsing
    // Extras returned by /status
    var serverTime: TimeInterval? // Changed to TimeInterval
    var apiVersion: String?
    var connectionProtocol: String?

    // New properties to match the WebSocket log data
    var initialTime: TimeValue?
    var startTime: TimeValue?
    var pauseStartTime: TimeInterval? // Changed to TimeInterval
    var totalPausedTime: TimeInterval? // Changed to TimeInterval
    var currentPauseDuration: TimeInterval? // Changed to TimeInterval
    var lastUpdateTime: TimeInterval? // Changed to TimeInterval
    
    private var decodedStatusKeys: Set<CodingKeys>?

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
        // New keys
        case initialTime
        case startTime
        case pauseStartTime
        case totalPausedTime
        case currentPauseDuration
        case lastUpdateTime
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        decodedStatusKeys = Set(container.allKeys)

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
        timeStamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timeStamp)
        serverTime = try container.decodeIfPresent(TimeInterval.self, forKey: .serverTime)
        apiVersion = try container.decodeIfPresent(String.self, forKey: .apiVersion)
        connectionProtocol = try container.decodeIfPresent(String.self, forKey: .connectionProtocol)
        // Decode new properties
        initialTime = try container.decodeIfPresent(TimeValue.self, forKey: .initialTime)
        startTime = try container.decodeIfPresent(TimeValue.self, forKey: .startTime)
        pauseStartTime = try container.decodeIfPresent(TimeInterval.self, forKey: .pauseStartTime)
        totalPausedTime = try container.decodeIfPresent(TimeInterval.self, forKey: .totalPausedTime)
        currentPauseDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .currentPauseDuration)
        lastUpdateTime = try container.decodeIfPresent(TimeInterval.self, forKey: .lastUpdateTime)
    }
}

extension ClockStatus {
    /// Returns `true` when at least one property differs from the default `ClockStatus` value.
    var hasAnyStatusFields: Bool {
        if let decodedStatusKeys {
            return !decodedStatusKeys.isEmpty
        }

        return self != ClockStatus()
    }
}

extension ClockStatus {
    func merging(_ patch: ClockStatus) -> ClockStatus {
        guard let patchKeys = patch.decodedStatusKeys else {
            return patch.hasAnyStatusFields ? patch : self
        }

        if patchKeys.isEmpty {
            return self
        }

        var merged = self

        for key in patchKeys {
            switch key {
            case .minutes:
                merged.minutes = patch.minutes
            case .seconds:
                merged.seconds = patch.seconds
            case .currentRound:
                merged.currentRound = patch.currentRound
            case .totalRounds:
                merged.totalRounds = patch.totalRounds
            case .isRunning:
                merged.isRunning = patch.isRunning
            case .isPaused:
                merged.isPaused = patch.isPaused
            case .elapsedMinutes:
                merged.elapsedMinutes = patch.elapsedMinutes
            case .elapsedSeconds:
                merged.elapsedSeconds = patch.elapsedSeconds
            case .isBetweenRounds:
                merged.isBetweenRounds = patch.isBetweenRounds
            case .betweenRoundsMinutes:
                merged.betweenRoundsMinutes = patch.betweenRoundsMinutes
            case .betweenRoundsSeconds:
                merged.betweenRoundsSeconds = patch.betweenRoundsSeconds
            case .betweenRoundsEnabled:
                merged.betweenRoundsEnabled = patch.betweenRoundsEnabled
            case .betweenRoundsTime:
                merged.betweenRoundsTime = patch.betweenRoundsTime
            case .warningLeadTime:
                merged.warningLeadTime = patch.warningLeadTime
            case .warningSoundPath:
                merged.warningSoundPath = patch.warningSoundPath
            case .endSoundPath:
                merged.endSoundPath = patch.endSoundPath
            case .ntpSyncEnabled:
                merged.ntpSyncEnabled = patch.ntpSyncEnabled
            case .ntpOffset:
                merged.ntpOffset = patch.ntpOffset
            case .endTime:
                merged.endTime = patch.endTime
            case .timeStamp:
                merged.timeStamp = patch.timeStamp
            case .serverTime:
                merged.serverTime = patch.serverTime
            case .apiVersion:
                merged.apiVersion = patch.apiVersion
            case .connectionProtocol:
                merged.connectionProtocol = patch.connectionProtocol
            case .initialTime:
                merged.initialTime = patch.initialTime
            case .startTime:
                merged.startTime = patch.startTime
            case .pauseStartTime:
                merged.pauseStartTime = patch.pauseStartTime
            case .totalPausedTime:
                merged.totalPausedTime = patch.totalPausedTime
            case .currentPauseDuration:
                merged.currentPauseDuration = patch.currentPauseDuration
            case .lastUpdateTime:
                merged.lastUpdateTime = patch.lastUpdateTime
            }
        }

        var combinedKeys = self.decodedStatusKeys ?? Set<CodingKeys>()
        combinedKeys.formUnion(patchKeys)
        merged.decodedStatusKeys = combinedKeys

        return merged
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
        lhs.connectionProtocol == rhs.connectionProtocol &&
        // Compare new properties
        lhs.initialTime == rhs.initialTime &&
        lhs.startTime == rhs.startTime &&
        lhs.pauseStartTime == rhs.pauseStartTime &&
        lhs.totalPausedTime == rhs.totalPausedTime &&
        lhs.currentPauseDuration == rhs.currentPauseDuration &&
        lhs.lastUpdateTime == rhs.lastUpdateTime
    }
}

extension ClockStatus {
    // This function is no longer the primary countdown mechanism,
    // but we'll leave it in case it's needed for other calculations.
    // The main countdown is now driven directly by the server's WebSocket updates.
    mutating func normalizeTimers(currentDate: Date = Date()) {
        guard shouldNormalizeMainTimer,
              let remainingSeconds = computeMainTimerSeconds(currentDate: currentDate) else {
            return
        }

        updateDecodedStatusKeys(for: [.minutes, .seconds])
        minutes = remainingSeconds / 60
        seconds = remainingSeconds % 60
    }

    private var shouldNormalizeMainTimer: Bool {
        isRunning && !isPaused && !isBetweenRounds && (endTime != nil || timeStamp != nil)
    }

    private mutating func updateDecodedStatusKeys(for keys: [CodingKeys]) {
        if decodedStatusKeys == nil {
            decodedStatusKeys = []
        }

        for key in keys {
            decodedStatusKeys?.insert(key)
        }
    }

    private func computeMainTimerSeconds(currentDate: Date) -> Int? {
        let timeStampDate = timeStamp.map { Date(timeIntervalSince1970: $0 / 1000.0) }

        guard let endDate = ClockStatusDateParser.parseEndTime(endTime) else {
            return nil
        }

        var referenceDate = currentDate
        if ntpSyncEnabled, ntpOffset != 0 {
            referenceDate = referenceDate.addingTimeInterval(TimeInterval(ntpOffset) / 1000.0)
        }

        if let timeStampDate = timeStampDate {
            let serverRemaining = endDate.timeIntervalSince(timeStampDate)
            if serverRemaining.isFinite {
                let elapsedSinceStamp = referenceDate.timeIntervalSince(timeStampDate)
                let remaining = Int((serverRemaining - elapsedSinceStamp).rounded(.down))
                return max(remaining, 0)
            }
        }

        let remaining = Int(endDate.timeIntervalSince(referenceDate).rounded(.down))
        return max(remaining, 0)
    }
}


private enum ClockStatusDateParser {
    // We are simplifying this since the server is providing numeric timestamps.
    // This is more robust.
    static func parseEndTime(_ endTime: String?) -> Date? {
        guard let string = endTime, !string.isEmpty else { return nil }

        if let numericValue = Double(string) {
            return Date(timeIntervalSince1970: numericValue / 1000.0)
        }

        // Fallback for ISO 8601 date strings if the server ever changes format
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) {
            return date
        }
        
        let basicFormatter = ISO8601DateFormatter()
        basicFormatter.formatOptions = [.withInternetDateTime]
        return basicFormatter.date(from: string)
    }
}