import SwiftUI

struct ControlView: View {
    @EnvironmentObject private var clockViewModel: ClockViewModel
    
    // A computed property to simplify the view's logic
    private var isTimerRunning: Bool {
        clockViewModel.status?.isRunning == true && clockViewModel.status?.isPaused == false
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    if let status = clockViewModel.status {
                        Text(String(format: "ELAPSED: %02d:%02d", status.elapsedMinutes, status.elapsedSeconds))
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        Text("ELAPSED: 00:00")
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                
                if let status = clockViewModel.status {
                    Text(String(format: "%02d:%02d", status.minutes, status.seconds))
                        .font(.system(size: 150, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("00:00")
                        .font(.system(size: 150, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if let status = clockViewModel.status {
                    Text(status.isRunning ? (status.isPaused ? "PAUSED" : "RUNNING") : "READY")
                        .font(.title)
                        .foregroundColor(status.isRunning ? (status.isPaused ? .black : .white) : .black)
                        .padding()
                        .background(status.isRunning ? (status.isPaused ? .orange : .green) : .gray)
                        .cornerRadius(10)
                } else {
                    Text("READY")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                
                if let status = clockViewModel.status {
                    Text("ROUND \(status.currentRound) of \(status.totalRounds)")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                } else {
                    Text("ROUND 0 of 0")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                }
                
                HStack(spacing: 10) {
                    Button(action: { Task { try? await clockViewModel.previousRound() } }) {
                        Image(systemName: "backward.end.fill")
                            .font(.title)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!clockViewModel.isConnected)
                    
                    Button(action: {
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
                    }) {
                        Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!clockViewModel.isConnected)
                    
                    Button(action: { Task { try? await clockViewModel.nextRound() } }) {
                        Image(systemName: "forward.end.fill")
                            .font(.title)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!clockViewModel.isConnected)
                    
                    Button(action: { Task { try? await clockViewModel.resetTime() } }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!clockViewModel.isConnected)
                    
                    Button(action: { Task { try? await clockViewModel.resetRounds() } }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!clockViewModel.isConnected)
                }
                
                HStack {
                    Circle()
                        .fill(clockViewModel.isConnected ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(clockViewModel.serverHost)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.leading)
                
                Spacer()
                
                if let status = clockViewModel.status, status.betweenRoundsEnabled {
                    Text(String(format: "Between Rounds Timer: %02d:%02d", status.betweenRoundsMinutes, status.betweenRoundsSeconds))
                        .foregroundColor(.purple)
                        .padding()
                }
            }
        }
    }
}