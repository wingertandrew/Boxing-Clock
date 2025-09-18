import Foundation

struct WSMessage: Codable {
    let type: String
    let data: ClockStatus?

    private enum CodingKeys: String, CodingKey {
        case type
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
        type = try container.decode(String.self, forKey: .type)

        if let decodedData = try container.decodeIfPresent(ClockStatus.self, forKey: .data) {
            data = decodedData
        } else if let decodedPayload = try container.decodeIfPresent(ClockStatus.self, forKey: .payload) {
            data = decodedPayload
        } else if let decodedStatus = try container.decodeIfPresent(ClockStatus.self, forKey: .status) {
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
