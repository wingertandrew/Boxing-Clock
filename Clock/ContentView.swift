import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clockViewModel: ClockViewModel

    var body: some View {
        MainTabView()
            .onAppear {
                clockViewModel.connect()
            }
    }
}