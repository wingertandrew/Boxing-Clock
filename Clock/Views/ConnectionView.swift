import SwiftUI

struct ConnectionView: View {
    @ObservedObject var clockViewModel: ClockViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Server Connection")) {
                    TextField("Server IP", text: $clockViewModel.serverHost)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Stepper("Port: \(clockViewModel.serverPort)",
                            value: $clockViewModel.serverPort,
                            in: 1...65535)
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
            }
            .navigationTitle("Connection")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
    }
}