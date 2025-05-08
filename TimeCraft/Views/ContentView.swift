import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .activities
    @ObservedObject var timerService: ActivityTimerService

    enum Tab {
        case activities
        case settings
    }

    init(timerService: ActivityTimerService) {
        self.timerService = timerService
        // Apply global Picker styling if desired (for SegmentedPickerStyle)
        // UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.appAccent)
        // UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        // UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.primaryText)], for: .normal)
        // Note: UISegmentedControl appearance is for UIKit. For pure SwiftUI on macOS, direct styling is different.
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Choose a tab", selection: $selectedTab) {
                Text("Activities").tag(Tab.activities)
                Text("Settings").tag(Tab.settings)
            }
            .pickerStyle(SegmentedPickerStyle())
            // .background(Color.secondaryBackground) // This might color the whole picker area
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 5)
            // Further Picker styling for macOS is often about how it interacts with its container.
            // We can achieve the look in the screenshot by careful padding and container colors.

            // Content based on selected tab
            Group {
                if selectedTab == .activities {
                    ActivitiesView(timerService: timerService)
                } else {
                    SettingsView(timerService: timerService)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Footer (like the reset button and version)
            // We can add this later when styling
        }
        .background(Color.appBackground) // Apply overall background color
        .edgesIgnoringSafeArea(.all) // Extend background to edges if popover allows
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(timerService: ActivityTimerService())
            .frame(width: 320, height: 450)
    }
} 