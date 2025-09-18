import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var minutes: Int
    @Published var seconds: Int
    @Published var totalRounds: Int
    @Published var betweenRoundsEnabled: Bool
    @Published var betweenRoundsTime: Int
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        // Initialize properties with saved values or sensible defaults
        self.minutes = userDefaults.object(forKey: "minutes") as? Int ?? 5
        self.seconds = userDefaults.object(forKey: "seconds") as? Int ?? 0
        self.totalRounds = userDefaults.object(forKey: "totalRounds") as? Int ?? 10
        self.betweenRoundsEnabled = userDefaults.object(forKey: "betweenRoundsEnabled") as? Bool ?? false
        self.betweenRoundsTime = userDefaults.object(forKey: "betweenRoundsTime") as? Int ?? 60
    }
    
    func loadSettings() {
        // This function is now effectively handled by the initializer,
        // but we can keep it for explicit reloads if needed in the future.
        minutes = userDefaults.object(forKey: "minutes") as? Int ?? 5
        seconds = userDefaults.object(forKey: "seconds") as? Int ?? 0
        totalRounds = userDefaults.object(forKey: "totalRounds") as? Int ?? 10
        betweenRoundsEnabled = userDefaults.object(forKey: "betweenRoundsEnabled") as? Bool ?? false
        betweenRoundsTime = userDefaults.object(forKey: "betweenRoundsTime") as? Int ?? 60
    }
    
    func saveSettings() {
        userDefaults.set(minutes, forKey: "minutes")
        userDefaults.set(seconds, forKey: "seconds")
        userDefaults.set(totalRounds, forKey: "totalRounds")
        userDefaults.set(betweenRoundsEnabled, forKey: "betweenRoundsEnabled")
        userDefaults.set(betweenRoundsTime, forKey: "betweenRoundsTime")
    }
    
    func applySettings(clockViewModel: ClockViewModel) async throws {
        // Save the settings locally first
        saveSettings()
        
        // Apply settings via API calls
        try await clockViewModel.setTime(minutes: minutes, seconds: seconds)
        try await clockViewModel.setRounds(totalRounds)
        try await clockViewModel.setBetweenRounds(enabled: betweenRoundsEnabled, time: betweenRoundsTime)
        
        // Reset the server's state to ensure it adopts the new settings
        try? await clockViewModel.reset()
        
        // Fetch the full status to ensure the UI is in sync
        try? await clockViewModel.fetchStatus()
    }
}