import SwiftUI

struct SettingsHubView: View {
    @EnvironmentObject private var clockViewModel: ClockViewModel
    @State private var selectedTab: SettingsTab = .connections

    var body: some View {
        VStack(spacing: 16) {
            Picker("Settings", selection: $selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Group {
                switch selectedTab {
                case .connections:
                    ConnectionsView()
                        .environmentObject(clockViewModel)
                case .status:
                    StatusView()
                        .environmentObject(clockViewModel)
                }
            }
        }
        .navigationTitle(selectedTab.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private enum SettingsTab: String, CaseIterable, Identifiable {
    case connections
    case status

    var id: String { rawValue }

    var title: String {
        switch self {
        case .connections:
            return "Connections"
        case .status:
            return "Status"
        }
    }

    var navigationTitle: String {
        title
    }
}
