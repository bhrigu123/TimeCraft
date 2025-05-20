import SwiftUI

struct SettingsView: View {
    @ObservedObject var timerService: GoalTimerService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Goals count and Add New button
            HStack {
                Text("Goals (\(timerService.goals.count))")
                    .font(.appHeadline)
                    .foregroundColor(.primaryText)
                Spacer()
                Button(action: addNewGoal) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add New").font(.appButton)
                    }
                    .foregroundColor(.appAccent)
                }
            }
            .padding()

            // List of goals using EditableGoalRowView
            List {
                let enumeratedGoals = Array(timerService.goals.enumerated())
                ForEach(enumeratedGoals, id: \.element.id) { index, goal in
                    EditableGoalRowView(
                        goal: Binding(
                            get: { goal },
                            set: { newValue in
                                var mutableGoals = timerService.goals
                                if let foundIndex = mutableGoals.firstIndex(where: { $0.id == newValue.id }) {
                                    mutableGoals[foundIndex] = newValue
                                    timerService.saveGoals(mutableGoals)
                                }
                            }
                        ),
                        onSave: { goalToSave in
                            var mutableGoals = timerService.goals
                            if let foundIndex = mutableGoals.firstIndex(where: { $0.id == goalToSave.id }) {
                                mutableGoals[foundIndex] = goalToSave
                                timerService.saveGoals(mutableGoals)
                            } else {
                                print("Error: Goal to save not found in the list for onSave callback.")
                            }
                        },
                        onDelete: {
                            var currentGoals = timerService.goals
                            if let foundIndex = currentGoals.firstIndex(where: { $0.id == goal.id }) {
                                if timerService.activeGoalID == goal.id {
                                    timerService.stopTimer()
                                }
                                currentGoals.remove(at: foundIndex)
                                timerService.saveGoals(currentGoals)
                            } else {
                                print("Error: Goal not found for deletion.")
                            }
                        }
                    )
                }
            }
            .listStyle(InsetListStyle())
            
            Spacer()

            // Footer
            HStack {
                Text("v1.0.0") // Consider making this dynamic from App Bundle
                    .font(.appCaption)
                    .foregroundColor(.secondaryText)
            }
            .padding()
        }
        .background(Color.appBackground.edgesIgnoringSafeArea(.all))
    }

    private func addNewGoal() {
        let newGoal = Goal(
            name: "New Goal", 
            targetDuration: 3600, // Default to 1 hour
            colorHex: Color.gray.toHex() ?? "#8E8E93", // Default to a generic color
            iconName: "list.star" // Default icon
        )
        var updatedGoals = timerService.goals
        updatedGoals.append(newGoal)
        timerService.saveGoals(updatedGoals)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock GoalTimerService for the preview
        let mockTimerService = GoalTimerService()
        
        SettingsView(timerService: mockTimerService)
            .frame(width: 350, height: 500) // Adjusted frame for better preview
    }
} 