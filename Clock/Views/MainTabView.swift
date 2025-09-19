import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var clockViewModel: ClockViewModel

    var body: some View {
        NavigationStack {
            ControlView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SettingsView()
                                .environmentObject(clockViewModel)
                        } label: {
                            Image(systemName: "gearshape")
                                .imageScale(.large)
                        }
                    }
                }
        }
    }
}