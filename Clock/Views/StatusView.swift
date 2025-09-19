import SwiftUI

struct StatusView: View {
    @EnvironmentObject var clockViewModel: ClockViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Connection")) {
                HStack {
                    Text("Server")
                    Spacer()
                    Text("\(clockViewModel.serverHost):\(clockViewModel.serverPort)")
                }
                
                HStack {
                    Text("Status")
                    Spacer()
                    Text(clockViewModel.isConnected ? "Connected" : "Disconnected")
                        .foregroundColor(clockViewModel.isConnected ? .green : .red)
                }
            }
            
            if let status = clockViewModel.status {
                Section(header: Text("Timer Status")) {
                    HStack {
                        Text("Running")
                        Spacer()
                        Text(status.isRunning ? "Yes" : "No")
                            .foregroundColor(status.isRunning ? .green : .red)
                    }
                    
                    HStack {
                        Text("Paused")
                        Spacer()
                        Text(status.isPaused ? "Yes" : "No")
                            .foregroundColor(status.isPaused ? .orange : .green)
                    }
                    
                    HStack {
                        Text("Between Rounds")
                        Spacer()
                        Text(status.isBetweenRounds ? "Yes" : "No")
                            .foregroundColor(status.isBetweenRounds ? .blue : .gray)
                    }
                }
                
                Section(header: Text("NTP Sync")) {
                    HStack {
                        Text("Enabled")
                        Spacer()
                        Text(status.ntpSyncEnabled ? "Yes" : "No")
                            .foregroundColor(status.ntpSyncEnabled ? .green : .red)
                    }
                    
                    if status.ntpSyncEnabled {
                        HStack {
                            Text("Offset")
                            Spacer()
                            Text("\(status.ntpOffset)ms")
                        }
                    }
                }
                
                if let apiVersion = status.apiVersion {
                    Section(header: Text("Server Info")) {
                        HStack {
                            Text("API Version")
                            Spacer()
                            Text(apiVersion)
                        }
                    }
                }
            }
        }
        .navigationTitle("Status")
    }
}