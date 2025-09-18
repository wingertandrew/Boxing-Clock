import SwiftUI

struct MainTabView: View {
    @ObservedObject var clockViewModel: ClockViewModel
    
    var body: some View {
        TabView {
            ControlView(clockViewModel: clockViewModel)
                .tabItem {
                    Label("Control", systemImage: "timer")
                }
            
            SettingsView(clockViewModel: clockViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            StatusView(clockViewModel: clockViewModel)
                .tabItem {
                    Label("Status", systemImage: "info.circle")
                }

            ConnectionView(clockViewModel: clockViewModel)
                .tabItem {
                    Label("Connection", systemImage: "network")
                }
        }
    }
}