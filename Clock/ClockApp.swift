import SwiftUI

@main
struct ClockApp: App {
    @StateObject private var clockViewModel = ClockViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(clockViewModel)
        }
    }
}