import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var clockViewModel: ClockViewModel
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ControlView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            ForEach(MainDestination.navigationOptions, id: \.self) { destination in
                                Button(destination.title) {
                                    navigate(to: destination)
                                }
                                .accessibilityIdentifier(destination.accessibilityIdentifier)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .imageScale(.large)
                        }
                    }
                }
                .navigationTitle("Control")
                .navigationDestination(for: MainDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
    }

    private func navigate(to destination: MainDestination) {
        if destination == .control {
            navigationPath = NavigationPath()
        } else {
            navigationPath = NavigationPath()
            navigationPath.append(destination)
        }
    }

    @ViewBuilder
    private func destinationView(for destination: MainDestination) -> some View {
        switch destination {
        case .connections:
            ConnectionsView()
                .environmentObject(clockViewModel)
        case .timeConfig:
            TimeConfigView()
                .environmentObject(clockViewModel)
        case .control:
            ControlView()
                .environmentObject(clockViewModel)
        case .status:
            StatusView()
                .environmentObject(clockViewModel)
        case .digitalFont:
            DigitalFontView()
        }
    }
}

private enum MainDestination: String, CaseIterable, Hashable {
    case connections
    case timeConfig
    case control
    case status
    case digitalFont

    static var navigationOptions: [MainDestination] {
        [.connections, .timeConfig, .control, .status, .digitalFont]
    }

    var title: String {
        switch self {
        case .connections:
            return "Connections"
        case .timeConfig:
            return "Time Config"
        case .control:
            return "Control"
        case .status:
            return "Status"
        case .digitalFont:
            return "Digital Font"
        }
    }

    var accessibilityIdentifier: String {
        "main_destination_\(rawValue)"
    }
}
