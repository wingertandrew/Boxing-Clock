import XCTest
@testable import Clock

final class StatusDecodingTests: XCTestCase {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    func testDecodeZeroStatusFromRESTPayload() throws {
        let payload = Data(#"{"status":{"minutes":0,"seconds":0}}"#.utf8)
        let api = ClockAPI(host: "example.com")

        let status = api.decodeStatusPayload(from: payload)

        XCTAssertNotNil(status)
        XCTAssertEqual(status?.minutes, 0)
        XCTAssertEqual(status?.seconds, 0)
    }

    func testDecodeZeroStatusFromWebSocketPayload() throws {
        let payload = Data(#"{"type":"status","data":{"minutes":0,"seconds":0}}"#.utf8)

        let message = try decoder.decode(WSMessage.self, from: payload)

        XCTAssertNotNil(message.data)
        XCTAssertEqual(message.data?.minutes, 0)
        XCTAssertEqual(message.data?.seconds, 0)
    }

    func testWebSocketPayloadMergesIntoExistingStatus() throws {
        var existingStatus = ClockStatus()
        existingStatus.minutes = 2
        existingStatus.seconds = 10
        existingStatus.currentRound = 3

        let payload = Data(#"{"type":"status","data":{"seconds":45}}"#.utf8)

        let message = try decoder.decode(WSMessage.self, from: payload)
        let patch = try XCTUnwrap(message.data)

        let mergedStatus = existingStatus.merging(patch)

        XCTAssertEqual(mergedStatus.minutes, 2)
        XCTAssertEqual(mergedStatus.seconds, 45)
        XCTAssertEqual(mergedStatus.currentRound, 3)
    }

    @MainActor
    func testActionAcknowledgementDoesNotResetTimer() throws {
        let viewModel = ClockViewModel()

        var initialStatus = ClockStatus()
        initialStatus.minutes = 3
        initialStatus.seconds = 15
        initialStatus.isRunning = true

        viewModel.status = initialStatus

        let payload = Data(#"{"type":"ack","status":{"isRunning":false}}"#.utf8)
        let message = try decoder.decode(WSMessage.self, from: payload)
        let patch = try XCTUnwrap(message.data)

        viewModel.applyStatusPatch(patch)

        XCTAssertEqual(viewModel.status?.minutes, 3)
        XCTAssertEqual(viewModel.status?.seconds, 15)
        XCTAssertEqual(viewModel.status?.isRunning, false)
    }
}
