import Foundation

struct StatusEnvelope: Decodable {
    let status: ClockStatus
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
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        if let envelope = try? decoder.decode(StatusEnvelope.self, from: data) {
            return envelope.status
        }

        if let status = try? decoder.decode(ClockStatus.self, from: data) {
            return status
        }

        throw URLError(.cannotDecodeContentData)
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