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
    private var hasAttemptedConnection = false
    
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
        guard !hasAttemptedConnection else { return }
        hasAttemptedConnection = true
        
        // Save server settings
        UserDefaults.standard.set(serverHost, forKey: "serverHost")
        UserDefaults.standard.set(serverPort, forKey: "serverPort")
        
        // Initialize API and WebSocket
        self.api = ClockAPI(host: serverHost, port: serverPort)
        
        let newWebSocket = ClockWebSocket()
        newWebSocket.onConnectionChanged = { [weak self] connected in
            DispatchQueue.main.async {
                self?.isConnected = connected
            }
        }
        newWebSocket.onStatusUpdate = { [weak self] patch in
            DispatchQueue.main.async {
                self?.applyStatusPatch(patch)
            }
        }
        self.webSocket = newWebSocket

        // Connect WebSocket
        newWebSocket.connect(host: serverHost, port: serverPort)
        
        // Always sync the app's settings to the server upon connection.
        Task {
            await syncSettingsToServer()
            do {
                try await fetchStatus()
            } catch {
                print("Failed to fetch initial status after sync: \(error.localizedDescription)")
            }
        }
    }
    
    private func syncSettingsToServer() async {
        print("Syncing app settings to server...")
        
        let settings = SettingsViewModel()
        
        do {
            try await api?.reset()
            try await api?.setTime(minutes: settings.minutes, seconds: settings.seconds)
            try await api?.setRounds(settings.totalRounds)
            try await api?.setBetweenRounds(enabled: settings.betweenRoundsEnabled, time: settings.betweenRoundsTime)
            print("Server sync complete.")
        } catch {
            print("Failed to sync settings to server: \(error.localizedDescription)")
        }
    }
    
    func disconnect() {
        webSocket?.disconnect()
        webSocket = nil
        api = nil
        self.isConnected = false
        // Don't nil out the status immediately to prevent flicker
        hasAttemptedConnection = false
    }
    
    func fetchStatus() async throws {
        guard let api = api else { return }
        let newStatus = try await api.fetchStatus()
        DispatchQueue.main.async {
            self.status = newStatus
        }
    }

    func applyStatusPatch(_ patch: ClockStatus) {
        if let existingStatus = status {
            let mergedStatus = existingStatus.merging(patch)
            if mergedStatus != existingStatus {
                status = mergedStatus
            }
        } else {
            status = patch
        }
    }

    // MARK: - API Actions
    
    func start() async throws { try await api?.start() }
    func pause() async throws { try await api?.pause() }
    func reset() async throws { try await api?.reset() }
    func resetTime() async throws { try await api?.resetTime() }
    func resetRounds() async throws { try await api?.resetRounds() }
    func nextRound() async throws { try await api?.nextRound() }
    func previousRound() async throws { try await api?.previousRound() }
    func setTime(minutes: Int, seconds: Int) async throws { try await api?.setTime(minutes: minutes, seconds: seconds) }
    func setRounds(_ rounds: Int) async throws { try await api?.setRounds(rounds) }
    func setBetweenRounds(enabled: Bool, time: Int) async throws { try await api?.setBetweenRounds(enabled: enabled, time: time) }
}