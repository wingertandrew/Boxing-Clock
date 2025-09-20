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
        case .settings:
            SettingsHubView()
                .environmentObject(clockViewModel)
        case .timeConfig:
            TimeConfigView()
                .environmentObject(clockViewModel)
        case .control:
            ControlView()
                .environmentObject(clockViewModel)
        case .digitalFont:
            DigitalFontView()
        }
    }
}

private enum MainDestination: String, CaseIterable, Hashable {

    case settings

    case control
    case digitalFont

    static var navigationOptions: [MainDestination] {

        [.settings, .control, .digitalFont]

    }

    var title: String {
        switch self {

        case .settings:
            return "Settings"

        case .control:
            return "Control"
        case .digitalFont:
            return "Digital Font"
        }
    }

    var accessibilityIdentifier: String {
        "main_destination_\(rawValue)"
    }
}
