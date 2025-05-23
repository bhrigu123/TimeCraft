import SwiftUI

// Define navigation states
enum NavigationState {
    case goals
    case configuration
    case stats
}

struct ContentView: View {
    @State private var navigationState: NavigationState = .goals
    @ObservedObject var timerService: GoalTimerService

    init(timerService: GoalTimerService) {
        self.timerService = timerService
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with navigation controls
            HStack {
                switch navigationState {
                case .goals:
                    // Configuration button
                    Button(action: { navigationState = .configuration }) {
                        Image(systemName: "wrench.adjustable")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Text("Today's goals")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    // Stats button
                    Button(action: { navigationState = .stats }) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                case .configuration, .stats:
                    // Back button
                    Button(action: { navigationState = .goals }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Title based on current view
                    Text(navigationState == .configuration ? "Configure Goals" : "Statistics")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    // Empty view for balance
                    Color.clear
                        .frame(width: 16, height: 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Content based on navigation state
            switch navigationState {
            case .goals:
                GoalsView(timerService: timerService)
                    .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity)
            case .configuration:
                ConfigureGoalsView(timerService: timerService)
                    .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity)
            case .stats:
                StatsView()
                    .frame(maxWidth: CGFloat.infinity, maxHeight: CGFloat.infinity)
            }
        }
        .background(Color.appBackground) 
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(timerService: GoalTimerService())
            .frame(width: 320, height: 450)
    }
} 