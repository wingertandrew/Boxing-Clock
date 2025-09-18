import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var clockViewModel: ClockViewModel

    var body: some View {
        MainTabView(clockViewModel: clockViewModel)
    }
}