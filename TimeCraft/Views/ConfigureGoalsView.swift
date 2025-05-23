import SwiftUI

struct ConfigureGoalsView: View {
    @ObservedObject var timerService: GoalTimerService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Full-width Add New button with glassy effect
            Button(action: addNewGoal) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.medium)
                    Text("Add New Goal")
                        .font(.appButton)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .foregroundColor(.appAccent)
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

struct ConfigureGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock GoalTimerService for the preview
        let mockTimerService = GoalTimerService()
        
        ConfigureGoalsView(timerService: mockTimerService)
            .frame(width: 350, height: 500) // Adjusted frame for better preview
    }
} 