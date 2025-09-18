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
    private var countdownTimer: Timer?
    
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
        self.api = ClockAPI(host: serverHost, port: serverPort)
        
        let newWebSocket = ClockWebSocket()
        newWebSocket.onConnectionChanged = { [weak self] connected in
            self?.isConnected = connected
        }
        newWebSocket.onStatusPatch = { [weak self] patch in
            self?.applyStatusPatch(patch)
        }
        self.webSocket = newWebSocket

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
    
    private func applyStatusPatch(_ patch: ClockStatus) {
        var mutablePatch = patch
        let now = Date()
        mutablePatch.normalizeTimers(currentDate: now)

        if var currentStatus = self.status {
            var merged = currentStatus.merging(mutablePatch)
            merged.normalizeTimers(currentDate: now)
            self.status = merged
        } else {
            self.status = mutablePatch
        }
        
        // Manage the countdown timer based on the new status
        if self.status?.isRunning == true && self.status?.isPaused == false {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    func disconnect() {
        webSocket?.disconnect()
        webSocket = nil
        api = nil
        self.isConnected = false
        self.status = nil
        stopTimer()
    }
    
    func fetchStatus() async throws {
        guard let api = api else { return }
        let newStatus = try await api.fetchStatus()
        applyStatusPatch(newStatus)
    }
    
    private func startTimer() {
        // Ensure we don't have multiple timers running
        stopTimer()
        // Start a new timer that updates the countdown every second
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCountdown()
        }
    }
    
    private func stopTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    private func updateCountdown() {
        guard var currentStatus = self.status else {
            stopTimer()
            return
        }
        currentStatus.normalizeTimers()
        self.status = currentStatus
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