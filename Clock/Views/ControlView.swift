import SwiftUI

struct ControlView: View {
    @ObservedObject private var clockViewModel: ClockViewModel
    
    init(clockViewModel: ClockViewModel) {
        self.clockViewModel = clockViewModel
    }
    
    var body: some View {
        Text("Control View")
    }
}