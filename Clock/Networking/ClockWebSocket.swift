import Foundation
import SwiftUI

final class ClockWebSocket: ObservableObject {
    @Published var status: ClockStatus?
    
    private var task: URLSessionWebSocketTask?
    private var isConnected = false

    func connect(host: String, port: Int = 4040) {
        // Close existing connection if any
        disconnect()
        
        let url = URL(string: "ws://\(host):\(port)")!
        task = URLSession.shared.webSocketTask(with: url)
        task?.resume()
        isConnected = true
        receive()
    }
    
    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        isConnected = false
    }

    private func receive() {
        guard isConnected, let task = task else { return }
        
        task.receive { [weak self] result in
            guard let self = self, self.isConnected else { return }
            
            switch result {
            case .success(.string(let text)):
                if let data = text.data(using: .utf8),
                   let message = try? JSONDecoder().decode(WSMessage.self, from: data),
                   message.type == "status" {
                    DispatchQueue.main.async { 
                        self.status = message.status
                    }
                }
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            default:
                break
            }
            
            // Continue receiving messages
            self.receive()
        }
    }
}