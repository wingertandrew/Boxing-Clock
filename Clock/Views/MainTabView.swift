import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var clockViewModel: ClockViewModel
    
    var body: some View {
        ControlView()
    }
}