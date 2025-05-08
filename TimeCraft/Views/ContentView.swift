import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .activities

    enum Tab {
        case activities
        case settings
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Choose a tab", selection: $selectedTab) {
                Text("Activities").tag(Tab.activities)
                Text("Settings").tag(Tab.settings)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Content based on selected tab
            Group {
                if selectedTab == .activities {
                    ActivitiesView()
                } else {
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Footer (like the reset button and version)
            // We can add this later when styling
        }
        // Remove the default frame from the original placeholder if it exists
        // .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure this line is removed if present from previous step
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 