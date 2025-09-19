import Foundation
import SwiftUI

final class ClockWebSocket: NSObject, URLSessionWebSocketDelegate {
    var onConnectionChanged: ((Bool) -> Void)?
    var onStatusUpdate: ((ClockStatus) -> Void)?
    
    private var task: URLSessionWebSocketTask?
    private var urlSession: URLSession?

    override init() {
        super.init()
    }

    func connect(host: String, port: Int = 4040) {
        disconnect()
        
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        let url = URL(string: "ws://\(host):\(port)")!
        task = urlSession!.webSocketTask(with: url)
        task?.resume()
    }
    
    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        onConnectionChanged?(false)
        urlSession?.finishTasksAndInvalidate()
        urlSession = nil
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected.")
        onConnectionChanged?(true)
        receive()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket disconnected.")
        onConnectionChanged?(false)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("WebSocket task completed with error: \(error.localizedDescription)")
        }
        onConnectionChanged?(false)
    }

    private func receive() {
        guard let task = task, task.state == .running else { return }
        
        task.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8) {
                        self?.decodeAndHandle(data: data)
                    }
                case .data(let data):
                    self?.decodeAndHandle(data: data)
                @unknown default:
                    break
                }
                self?.receive()
            case .failure(let error):
                print("WebSocket receive error: \(error.localizedDescription)")
                self?.disconnect()
            }
        }
    }
    
    private func decodeAndHandle(data: Data) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let status = try decoder.decode(ClockStatus.self, from: data)
            onStatusUpdate?(status)
        } catch {
            print("Failed to decode ClockStatus: \(error)")
        }
    }
}