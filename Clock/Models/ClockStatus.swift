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
        timeStamp = try container.decodeIfPresent(String.self, forKey: .timeStamp)
        serverTime = try container.decodeIfPresent(Int.self, forKey: .serverTime)
        apiVersion = try container.decodeIfPresent(String.self, forKey: .apiVersion)
        connectionProtocol = try container.decodeIfPresent(String.self, forKey: .connectionProtocol)
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
        lhs.connectionProtocol == rhs.connectionProtocol
    }
}

extension ClockStatus {
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
        isRunning && !isPaused && !isBetweenRounds && minutes == 0 && seconds == 0 && (endTime != nil || timeStamp != nil)
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
        let timeStampResult = ClockStatusDateParser.parseTimeStamp(timeStamp, serverTime: serverTime)
        let offset = timeStampResult?.offset
        let timeStampDate = timeStampResult?.date

        guard let endDate = ClockStatusDateParser.parseEndTime(endTime, appliedOffset: offset) else {
            return nil
        }

        var referenceDate = currentDate

        if ntpSyncEnabled, ntpOffset != 0 {
            referenceDate = referenceDate.addingTimeInterval(TimeInterval(ntpOffset) / 1000.0)
        }

        if let timeStampDate {
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
    private static let iso8601WithFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let fallbackFormatters: [DateFormatter] = {
        let patterns = [
            "yyyy-MM-dd HH:mm:ss.SSSSSS",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]

        var formatters: [DateFormatter] = []

        for pattern in patterns {
            let utcFormatter = DateFormatter()
            utcFormatter.locale = Locale(identifier: "en_US_POSIX")
            utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            utcFormatter.dateFormat = pattern
            formatters.append(utcFormatter)

            let localFormatter = DateFormatter()
            localFormatter.locale = Locale(identifier: "en_US_POSIX")
            localFormatter.timeZone = TimeZone.current
            localFormatter.dateFormat = pattern
            formatters.append(localFormatter)
        }

        return formatters
    }()

    static func parseTimeStamp(_ timeStamp: String?, serverTime: Int?) -> (date: Date, offset: TimeInterval)? {
        let parsed = parse(timeStamp)

        if let parsed {
            if let serverTime {
                let serverDate = date(fromServerTime: serverTime)
                let delta = serverDate.timeIntervalSince(parsed)
                if abs(delta) > 1 {
                    return (parsed.addingTimeInterval(delta), delta)
                }
            }

            return (parsed, 0)
        }

        if let serverTime {
            let serverDate = date(fromServerTime: serverTime)
            return (serverDate, 0)
        }

        return nil
    }

    static func parseEndTime(_ endTime: String?, appliedOffset: TimeInterval?) -> Date? {
        guard var date = parse(endTime) else { return nil }

        if let offset = appliedOffset, abs(offset) > 1 {
            date = date.addingTimeInterval(offset)
        }

        return date
    }

    private static func parse(_ string: String?) -> Date? {
        guard let string = string, !string.isEmpty else { return nil }

        if let date = iso8601WithFractional.date(from: string) {
            return date
        }

        if let date = iso8601.date(from: string) {
            return date
        }

        for formatter in fallbackFormatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }

        if let numericValue = Double(string) {

            if numericValue > 9_999_999_999 {

                return Date(timeIntervalSince1970: numericValue / 1000.0)
            }

            return Date(timeIntervalSince1970: numericValue)
        }

        return nil
    }

    private static func date(fromServerTime serverTime: Int) -> Date {
        if serverTime > 9_999_999_999 {
            return Date(timeIntervalSince1970: TimeInterval(serverTime) / 1000.0)
        }

        return Date(timeIntervalSince1970: TimeInterval(serverTime))
    }
}
