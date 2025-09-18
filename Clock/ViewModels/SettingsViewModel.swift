import Foundation
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var minutes = 3
    @Published var seconds = 0
    @Published var totalRounds = 12
    @Published var betweenRoundsEnabled = true
    @Published var betweenRoundsTime = 60
    
    private let clockViewModel: ClockViewModel
    
    init(clockViewModel: ClockViewModel) {
        self.clockViewModel = clockViewModel
        // Load saved settings
        loadSettings()
    }
    
    func saveSettings() {
        UserDefaults.standard.set(minutes, forKey: "defaultMinutes")
        UserDefaults.standard.set(seconds, forKey: "defaultSeconds")
        UserDefaults.standard.set(totalRounds, forKey: "defaultTotalRounds")
        UserDefaults.standard.set(betweenRoundsEnabled, forKey: "defaultBetweenRoundsEnabled")
        UserDefaults.standard.set(betweenRoundsTime, forKey: "defaultBetweenRoundsTime")
    }
    
    func loadSettings() {
        minutes = UserDefaults.standard.integer(forKey: "defaultMinutes") != 0 ? UserDefaults.standard.integer(forKey: "defaultMinutes") : 3
        seconds = UserDefaults.standard.integer(forKey: "defaultSeconds")
        totalRounds = UserDefaults.standard.integer(forKey: "defaultTotalRounds") != 0 ? UserDefaults.standard.integer(forKey: "defaultTotalRounds") : 12
        betweenRoundsEnabled = UserDefaults.standard.bool(forKey: "defaultBetweenRoundsEnabled")
        betweenRoundsTime = UserDefaults.standard.integer(forKey: "defaultBetweenRoundsTime") != 0 ? UserDefaults.standard.integer(forKey: "defaultBetweenRoundsTime") : 60
    }
    
    func applySettings() async throws {
        try await clockViewModel.setTime(minutes: minutes, seconds: seconds)
        try await clockViewModel.setRounds(totalRounds)
        try await clockViewModel.setBetweenRounds(enabled: betweenRoundsEnabled, time: betweenRoundsTime)
        saveSettings()
    }
}