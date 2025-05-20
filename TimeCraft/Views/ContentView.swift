import SwiftUI

struct ContentView: View {
    @State private var showSettings: Bool = false
    @ObservedObject var timerService: GoalTimerService

    init(timerService: GoalTimerService) {
        self.timerService = timerService
        // Apply global Picker styling if desired (for SegmentedPickerStyle)
        // UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.appAccent)
        // UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        // UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.primaryText)], for: .normal)
        // Note: UISegmentedControl appearance is for UIKit. For pure SwiftUI on macOS, direct styling is different.
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with title and settings icon
            HStack {
                if showSettings {
                    // Back button when in settings
                    Button(action: { showSettings = false }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    // Empty view for balance
                    Color.clear
                        .frame(width: 16, height: 16)
                } else {
                    // Empty space to balance the gear button
                    Color.clear
                        .frame(width: 16, height: 16)
                        
                    Spacer()
                    
                    // Title for goals view
                    Text("Today's goals")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Content based on navigation state
            if showSettings {
                SettingsView(timerService: timerService)
                    .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity)
            } else {
                GoalsView(timerService: timerService)
                    .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity)
            }
            
            // Footer (like the reset button and version)
            // We can add this later when styling
        }
        .background(Color.appBackground) // Apply overall background color
        .edgesIgnoringSafeArea(.all) // Extend background to edges if popover allows
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(timerService: GoalTimerService())
            .frame(width: 320, height: 450)
    }
} 