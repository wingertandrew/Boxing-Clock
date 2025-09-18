import Foundation
import SwiftUI
import Combine

@MainActor
final class ClockViewModel: ObservableObject {
    @Published var status: ClockStatus?
    @Published var isConnected = false
    @Published var serverHost = "127.0.0.1"
    @Published var serverPort = 4040
    
    private var webSocket: ClockWebSocket?
    private var api: ClockAPI?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load saved server settings
        if let savedHost = UserDefaults.standard.string(forKey: "serverHost") {
            serverHost = savedHost
        }
        if UserDefaults.standard.object(forKey: "serverPort") != nil {
            serverPort = UserDefaults.standard.integer(forKey: "serverPort")
        }
    }
    
    func connect() {
        // Save server settings
        UserDefaults.standard.set(serverHost, forKey: "serverHost")
        UserDefaults.standard.set(serverPort, forKey: "serverPort")
        
        // Initialize API and WebSocket
        let newApi = ClockAPI(host: serverHost, port: serverPort)
        let newWebSocket = ClockWebSocket()
        
        self.api = newApi
        self.webSocket = newWebSocket
        
        // The WebSocket is the single source of truth for status updates
        newWebSocket.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.status, on: self)
            .store(in: &cancellables)
        
        newWebSocket.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
        
        // Connect WebSocket
        newWebSocket.connect(host: serverHost, port: serverPort)
        
        // Fetch initial status
        Task {
            do {
                try await fetchStatus()
            } catch {
                print("Failed to fetch initial status: \(error.localizedDescription)")
            }
        }
    }
    
    func disconnect() {
        webSocket?.disconnect()
        webSocket = nil
        api = nil
        self.isConnected = false
        self.status = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func fetchStatus() async throws {
        guard let api = api else { return }
        var newStatus = try await api.fetchStatus()
        newStatus.normalizeTimers()
        await MainActor.run {
            self.status = newStatus
        }
    }
    
    // All actions simply send a command. The UI will update when the new
    // status arrives via the WebSocket.
    
    func start() async throws {
        try await api?.start()
    }
    
    func pause() async throws {
        try await api?.pause()
    }
    
    func reset() async throws {
        try await api?.reset()
    }
    
    func resetTime() async throws {
        try await api?.resetTime()
    }
    
    func resetRounds() async throws {
        try await api?.resetRounds()
    }
    
    func nextRound() async throws {
        try await api?.nextRound()
    }
    
    func previousRound() async throws {
        try await api?.previousRound()
    }
    
    func setTime(minutes: Int, seconds: Int) async throws {
        try await api?.setTime(minutes: minutes, seconds: seconds)
    }
    
    func setRounds(_ rounds: Int) async throws {
        try await api?.setRounds(rounds)
    }
    
    func setBetweenRounds(enabled: Bool, time: Int) async throws {
        try await api?.setBetweenRounds(enabled: enabled, time: time)
    }
}