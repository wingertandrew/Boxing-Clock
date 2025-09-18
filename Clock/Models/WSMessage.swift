import Foundation

struct WSMessage: Codable {
    let type: String
    let data: ClockStatus?

    private enum CodingKeys: String, CodingKey {
        case type
        case event
        case data
        case status
        case payload
    }

    init(type: String, data: ClockStatus?) {
        self.type = type
        self.data = data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let decodedType = try container.decodeIfPresent(String.self, forKey: .type) {
            type = decodedType
        } else if let decodedEvent = try container.decodeIfPresent(String.self, forKey: .event) {
            type = decodedEvent
        } else if container.contains(.data) || container.contains(.payload) || container.contains(.status) {
            type = "status"
        } else {
            type = ""
        }

        func decodeStatus(for key: CodingKeys) -> ClockStatus? {
            guard let status = try? container.decodeIfPresent(ClockStatus.self, forKey: key),
                  status.hasAnyStatusFields else {
                return nil
            }
            return status
        }

        if let decodedData = decodeStatus(for: .data) {
            data = decodedData
        } else if let decodedPayload = decodeStatus(for: .payload) {
            data = decodedPayload
        } else if let decodedStatus = decodeStatus(for: .status) {
            data = decodedStatus
        } else {
            data = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(data, forKey: .data)
    }
}
