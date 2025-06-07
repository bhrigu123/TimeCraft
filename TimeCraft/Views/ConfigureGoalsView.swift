import SwiftUI

struct ConfigureGoalsView: View {
    @ObservedObject var timerService: GoalTimerService
    @StateObject private var versionService = VersionService()
    @State private var shouldScrollToTop = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Add New button
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

            // List of goals
            if timerService.goals.isEmpty {
                VStack {
                    Text("Add a goal to get started")
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBackground) 
            } else {
                ScrollViewReader { proxy in
                    List {
                        ForEach(timerService.goals, id: \.id) { goal in
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
                            .id(goal.id) // Add id for scrolling
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onMove(perform: timerService.reorderGoals)
                    }
                    .listStyle(PlainListStyle())
                    .onChange(of: timerService.goals.count) { newCount in
                        if shouldScrollToTop {
                            withAnimation {
                                if let firstGoal = timerService.goals.first {
                                    proxy.scrollTo(firstGoal.id, anchor: .top)
                                }
                            }
                            shouldScrollToTop = false
                        }
                    }
                }
            }
            
            Spacer()

            // Footer
            footerView
        }
        .background(Color.appBackground.edgesIgnoringSafeArea(.all))
    }

    private func addNewGoal() {
        shouldScrollToTop = true
        timerService.createNewGoal()
    }
    
    @ViewBuilder
    private var footerView: some View {
        HStack {
            Spacer()
            HStack(spacing: 5) {
                Text("v\(versionService.currentVersion)")
                    .font(.appCaption)
                    .foregroundColor(.secondaryText)

                if versionService.hasUpdate {
                    Text("(Update available)")
                        .font(.appCaption)
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            versionService.openReleasesPage()
                        }
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct ConfigureGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        let mockTimerService = GoalTimerService()
        
        ConfigureGoalsView(timerService: mockTimerService)
            .frame(width: 350, height: 500) 
    }
} 