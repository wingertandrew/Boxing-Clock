import Foundation

struct StatusEnvelope: Decodable {
    let status: ClockStatus
}

enum ClockAPIError: LocalizedError {
    case unexpectedStatusPayload

    var errorDescription: String? {
        "The server returned the status in an unexpected format."
    }
}

// Struct for between rounds configuration
struct BetweenRoundsConfig: Codable {
    let enabled: Bool
    let time: Int
}

// Struct for time configuration
struct TimeConfig: Codable {
    let minutes: Int
    let seconds: Int
}

// Struct for rounds configuration
struct RoundsConfig: Codable {
    let rounds: Int
}

final class ClockAPI {
    private static let statusFieldKeys: Set<String> = [
        "minutes",
        "seconds",
        "currentround",
        "totalrounds",
        "isrunning",
        "ispaused",
        "elapsedminutes",
        "elapsedseconds",
        "isbetweenrounds",
        "betweenroundsminutes",
        "betweenroundsseconds",
        "betweenroundsenabled",
        "betweenroundstime",
        "warningleadtime",
        "warningsoundpath",
        "endsoundpath",
        "ntpsyncenabled",
        "ntpoffset",
        "endtime",
        "timestamp",
        "servertime",
        "apiversion",
        "connectionprotocol",
    ]

    var baseURL: URL

    init(host: String, port: Int = 4040) {
        self.baseURL = URL(string: "http://\(host):\(port)/api")!
    }

    func post(_ path: String, body: Data? = nil) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        _ = try await URLSession.shared.data(for: request)
    }

    func fetchStatus() async throws -> ClockStatus {
        let url = baseURL.appendingPathComponent("status")
        let (data, _) = try await URLSession.shared.data(from: url)

        if let status = decodeStatusPayload(from: data) {
            return status
        }

        throw ClockAPIError.unexpectedStatusPayload
    }

    private func decodeStatusPayload(from data: Data) -> ClockStatus? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        if let envelope = try? decoder.decode(StatusEnvelope.self, from: data),
           envelope.status.hasAnyStatusFields {
            return envelope.status
        }


        if let message = try? decoder.decode(WSMessage.self, from: data),
           let status = message.data,
           status.hasAnyStatusFields {
            return status
        }



        if let status = try? decoder.decode(ClockStatus.self, from: data),
           status.hasAnyStatusFields {
            return status
        }


        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }

        return extractStatus(from: jsonObject, using: decoder)
    }

    private func extractStatus(from object: Any, using decoder: JSONDecoder) -> ClockStatus? {
        if let dictionary = object as? [String: Any] {
            if dictionaryContainsStatusData(dictionary),
               JSONSerialization.isValidJSONObject(dictionary),
               let data = try? JSONSerialization.data(withJSONObject: dictionary),
               let status = try? decoder.decode(ClockStatus.self, from: data),
               status.hasAnyStatusFields {
                return status
            }

            for value in dictionary.values {
                if let status = extractStatus(from: value, using: decoder) {
                    return status
                }
            }
        } else if let array = object as? [Any] {
            for element in array {
                if let status = extractStatus(from: element, using: decoder) {
                    return status
                }
            }
        }

        return nil
    }

    private func dictionaryContainsStatusData(_ dictionary: [String: Any]) -> Bool {
        for key in dictionary.keys {
            let normalizedKey = key.replacingOccurrences(of: "_", with: "").lowercased()
            if Self.statusFieldKeys.contains(normalizedKey) {
                return true
            }
        }

        return false

    }
}

extension ClockAPI {
    func start() async throws { try await post("start") }
    func pause() async throws { try await post("pause") }
    func reset() async throws { try await post("reset") }
    func resetTime() async throws { try await post("reset-time") }
    func resetRounds() async throws { try await post("reset-rounds") }
    func nextRound() async throws { try await post("next-round") }
    func previousRound() async throws { try await post("previous-round") }

    func setTime(minutes: Int, seconds: Int) async throws {
        let config = TimeConfig(minutes: minutes, seconds: seconds)
        let body = try JSONEncoder().encode(config)
        try await post("set-time", body: body)
    }

    func setRounds(_ rounds: Int) async throws {
        let config = RoundsConfig(rounds: rounds)
        let body = try JSONEncoder().encode(config)
        try await post("set-rounds", body: body)
    }

    func setBetweenRounds(enabled: Bool, time: Int) async throws {
        let config = BetweenRoundsConfig(enabled: enabled, time: time)
        let body = try JSONEncoder().encode(config)
        try await post("set-between-rounds", body: body)
    }
}