import SwiftUI

struct GoalsView: View {
    @AppStorage("goals") private var goalsData: Data = Data()
    @ObservedObject var timerService: GoalTimerService 

    private var goals: [Goal] {
        // Decode goals, providing an empty array or default if necessary
        // Ensure this matches the decoding logic in SettingsView for consistency
        if let decodedGoals = try? JSONDecoder().decode([Goal].self, from: goalsData) {
            return decodedGoals
        } else {
            return [] 
        }
    }

    var body: some View {
        if goals.isEmpty {
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
                    ForEach(goals) { goal in
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
        let sampleGoalsData: () -> Data = {
            let goals = [
                Goal(name: "Deep Work", targetDuration: 2 * 3600, elapsedTime: 35 * 60, colorHex: "#5E5CE6", iconName: "moon.fill"),
                Goal(name: "Reading", targetDuration: 1 * 3600, elapsedTime: 15 * 60, colorHex: "#BF5AF2", iconName: "book.fill"),
                Goal(name: "Exercise", targetDuration: 45 * 60, elapsedTime: 0, colorHex: "#32ADE6", iconName: "figure.walk")
            ]
            return (try? JSONEncoder().encode(goals)) ?? Data()
        }
        
        let mockTimerService = GoalTimerService()

        GoalsView(timerService: mockTimerService)
            .onAppear {
                UserDefaults.standard.setValue(sampleGoalsData(), forKey: "goals")
            }
            .frame(width: 320, height: 450)
            .background(Color.appBackground) 
    }
} 