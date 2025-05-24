import SwiftUI

struct GoalsView: View {
    @ObservedObject var timerService: GoalTimerService 
    @Binding var navigationState: NavigationState

    var body: some View {
        if timerService.goals.isEmpty {
            VStack {
                Text("No Goals Added")
                    .font(.title2)
                    .fontWeight(.semibold)

                Button(action: {
                    navigationState = .configuration
                }) {
                    HStack {
                        Image(systemName: "wrench")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                        Text("Configure Goals")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground) 
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(timerService.goals) { goal in
                        GoalCardView(goal: goal, timerService: timerService)
                    }
                }
                .padding()
            }
            .background(Color.appBackground) 
        }
    }
}

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        let mockTimerService = GoalTimerService()
        
        // Add some sample goals through the service
        let sampleGoals = [
            Goal(name: "Deep Work", targetDuration: 2 * 3600, elapsedTime: 35 * 60, colorHex: "#5E5CE6", iconName: "moon.fill"),
            Goal(name: "Reading", targetDuration: 1 * 3600, elapsedTime: 15 * 60, colorHex: "#BF5AF2", iconName: "book.fill"),
            Goal(name: "Exercise", targetDuration: 45 * 60, elapsedTime: 0, colorHex: "#32ADE6", iconName: "figure.walk")
        ]
        mockTimerService.saveGoals(sampleGoals)

        return GoalsView(timerService: mockTimerService, navigationState: .constant(.goals))
            .frame(width: 320, height: 450)
            .background(Color.appBackground) 
    }
} 