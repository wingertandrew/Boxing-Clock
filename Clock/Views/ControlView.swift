import SwiftUI

struct ControlView: View {
    @EnvironmentObject private var clockViewModel: ClockViewModel
    
    private var isTimerRunning: Bool {
        clockViewModel.status?.isRunning == true && !clockViewModel.status!.isPaused
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    elapsedTimeView()
                        .padding(.top, 30)

                    Spacer()
                    
                    mainTimerView()
                    
                    statusBar()
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .onTapGesture {
                            Task {
                                do {
                                    if isTimerRunning {
                                        try await clockViewModel.pause()
                                    } else {
                                        try await clockViewModel.start()
                                    }
                                } catch {
                                    print("Failed to perform action: \(error.localizedDescription)")
                                }
                            }
                        }

                    roundInfoView()
                        .padding(.top, 12)

                    Spacer()

                    connectionInfoView()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 12)

                    controlButtons()
                        .padding(.bottom, 30)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                
            }
        }
        .statusBar(hidden: true)
    }
    
    @ViewBuilder
    private func statusBar() -> some View {
        Label {
            Text(getStatusText())
                .digitalFont(size: 24)
        } icon: {
            Image(systemName: getStatusIconName())
                .font(.system(size: 20, weight: .semibold))
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .padding()
        .background(getStatusColor())
        .cornerRadius(12)
    }
    
    private func mainTimerView() -> some View {
        let displayText = clockViewModel.status
            .map { String(format: "%02d:%02d", $0.minutes, $0.seconds) }
            ?? "00:00"

        return Text(displayText)
            .digitalFont(size: 150, weight: .black)
            .foregroundColor(.white)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .padding(.horizontal, 60)
            .padding(.vertical, 30)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(getStatusColor(), lineWidth: 10)
            )
    }
    
    @ViewBuilder
    private func elapsedTimeView() -> some View {
        if let status = clockViewModel.status {
            Text(String(format: "ELAPSED: %02d:%02d", status.elapsedMinutes, status.elapsedSeconds))
                .digitalFont(size: 36)
                .foregroundColor(.white)
        } else {
            Text("ELAPSED: 00:00")
                .digitalFont(size: 36)
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private func connectionInfoView() -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(clockViewModel.isConnected ? .green : .red)
                .frame(width: 10, height: 10)
            Text(clockViewModel.serverHost)
                .font(.body)
                .foregroundColor(.gray)
        }
    }
    
    @ViewBuilder
    private func roundInfoView() -> some View {
        Group {
            if let status = clockViewModel.status {
                Text("ROUND \(status.currentRound) of \(status.totalRounds)")
            } else {
                Text("ROUND 0 of 0")
            }
        }
        .digitalFont(size: 44)
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    private func controlButtons() -> some View {
        HStack(spacing: 6) {
            Group {
                controlButton(systemName: "minus") {}
                controlButton(systemName: "plus") {}
                controlButton(systemName: "backward.end.fill") {
                    Task { try? await clockViewModel.previousRound() }
                }
                controlButton(systemName: "forward.end.fill") {
                    Task { try? await clockViewModel.nextRound() }
                }
                controlButton(systemName: "arrow.counterclockwise") {
                    Task { try? await clockViewModel.resetTime() }
                }
                controlButton(systemName: "arrow.counterclockwise.circle") {
                    Task { try? await clockViewModel.resetRounds() }
                }
            }
            .disabled(!clockViewModel.isConnected)
        }
    }
    
    private func controlButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .frame(minWidth: 80, minHeight: 50)
                .background(Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    private func getStatusText() -> String {
        guard let status = clockViewModel.status, status.isRunning else { return "READY" }
        return status.isPaused ? "PAUSED" : "RUNNING"
    }

    private func getStatusIconName() -> String {
        guard let status = clockViewModel.status, status.isRunning, !status.isPaused else { return "play.fill" }
        return "pause.fill"
    }

    private func getStatusColor() -> Color {
        guard let status = clockViewModel.status, status.isRunning else { return .gray }
        if status.isBetweenRounds {
            return .purple
        }
        return status.isPaused ? .yellow : .green
    }
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView()
            .environmentObject(ClockViewModel())
    }
}