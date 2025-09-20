import SwiftUI

struct ConnectionsView: View {
    @EnvironmentObject var clockViewModel: ClockViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some View {
        Form {
            Section(header: Text("Server Connection")) {
                TextField("Server IP", text: $clockViewModel.serverHost)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                Stepper(
                    "Port: \(clockViewModel.serverPort)",
                    value: $clockViewModel.serverPort,
                    in: 1...65535
                )
            }

            Section {
                Button(clockViewModel.isConnected ? "Disconnect" : "Connect") {
                    if clockViewModel.isConnected {
                        clockViewModel.disconnect()
                    } else {
                        clockViewModel.connect()
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Section(header: Text("Timer Settings")) {
                Stepper(
                    "Minutes: \(settingsViewModel.minutes)",
                    value: $settingsViewModel.minutes,
                    in: 0...60
                )

                Stepper(
                    "Seconds: \(settingsViewModel.seconds)",
                    value: $settingsViewModel.seconds,
                    in: 0...59
                )
            }

            Section(header: Text("Round Settings")) {
                Stepper(
                    "Total Rounds: \(settingsViewModel.totalRounds)",
                    value: $settingsViewModel.totalRounds,
                    in: 1...99
                )
            }

            Section(header: Text("Between Rounds")) {
                Toggle("Enable Between Rounds", isOn: $settingsViewModel.betweenRoundsEnabled)

                if settingsViewModel.betweenRoundsEnabled {
                    Stepper(
                        "Time: \(settingsViewModel.betweenRoundsTime)s",
                        value: $settingsViewModel.betweenRoundsTime,
                        in: 10...300
                    )
                }
            }

            Section {
                Button("Apply Settings") {
                    Task {
                        try? await settingsViewModel.applySettings(clockViewModel: clockViewModel)
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(!clockViewModel.isConnected)
            }
        }
        .navigationTitle("Connections")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            settingsViewModel.loadSettings()
        }
    }
}
