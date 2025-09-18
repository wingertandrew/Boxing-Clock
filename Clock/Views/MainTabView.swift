import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var clockViewModel: ClockViewModel
    
    var body: some View {
        TabView {
            ControlView()
                .tabItem {
                    Label("Control", systemImage: "timer")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            StatusView()
                .tabItem {
                    Label("Status", systemImage: "info.circle")
                }
            
            ConnectionView()
                .tabItem {
                    Label("Connection", systemImage: "network")
                }
        }
        .onAppear {
            clockViewModel.connect()
        }
    }
}