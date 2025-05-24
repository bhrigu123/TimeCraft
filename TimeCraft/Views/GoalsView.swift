import SwiftUI

struct GoalsView: View {
    @ObservedObject var timerService: GoalTimerService 

    var body: some View {
        if timerService.goals.isEmpty {
            VStack {
                Text("No Goals")
                    .font(.appHeadline) 
                    .foregroundColor(.primaryText)
                Text("Go to Settings to add new goals.")
                    .font(.appSubheadline) 
                    .foregroundColor(.secondaryText)
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

        return GoalsView(timerService: mockTimerService)
            .frame(width: 320, height: 450)
            .background(Color.appBackground) 
    }
} 