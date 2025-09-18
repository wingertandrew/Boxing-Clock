import Foundation
import SwiftUI

final class ClockWebSocket: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    @Published var status: ClockStatus?
    @Published var isConnected = false
    
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
        self.isConnected = false
        urlSession?.finishTasksAndInvalidate()
        urlSession = nil
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected.")
        self.isConnected = true
        receive()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket disconnected.")
        self.isConnected = false
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("WebSocket task completed with error: \(error.localizedDescription)")
            self.isConnected = false
        }
    }

    private func receive() {
        guard let task = task, task.state == .running else { return }
        
        task.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8) {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        if let wsMessage = try? decoder.decode(WSMessage.self, from: data),
                           wsMessage.type == "status" {
                            if var patch = wsMessage.data {
                                let now = Date()
                                patch.normalizeTimers(currentDate: now)

                                if var currentStatus = self?.status {
                                    var merged = currentStatus.merging(patch)
                                    merged.normalizeTimers(currentDate: now)
                                    self?.status = merged
                                } else {
                                    self?.status = patch
                                }
                            } else {
                                self?.status = nil
                            }
                        }
                    }
                case .data:
                    break
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
}
