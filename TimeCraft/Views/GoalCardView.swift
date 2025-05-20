import SwiftUI

struct GoalCardView: View {
    // Use a non-optional Goal, ensure it's always passed correctly
    let goal: Goal 
    @ObservedObject var timerService: GoalTimerService

    private var isThisGoalActive: Bool {
        timerService.activeGoalID == goal.id
    }

    private var currentDisplayElapsedTime: TimeInterval {
        isThisGoalActive ? timerService.currentElapsedTimeForActiveGoal : goal.todayProgress
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.name)
                    .font(.appFont(size: 20, weight: .semibold))
                    .foregroundColor(.primaryText)
                Spacer()
                Button(action: {
                    if isThisGoalActive {
                        timerService.stopTimer()
                    } else {
                        timerService.startTimer(for: goal.id)
                    }
                }) {
                    Image(systemName: isThisGoalActive ? "pause.fill" : "play.fill")
                        .font(.appFont(size: 20, weight: .semibold))
                        .foregroundColor(.appAccent)
                }
                .buttonStyle(PlainButtonStyle())
            }

            ProgressView(value: currentDisplayElapsedTime, total: goal.targetDuration > 0 ? goal.targetDuration : 1)
                .progressViewStyle(LinearProgressViewStyle(tint: goal.color))

            HStack {
                Text("\(formatTimeInterval(currentDisplayElapsedTime)) spent")
                    .font(.appCaption)
                    .foregroundColor(.secondaryText)
                Spacer()
                Text("\(formatTimeInterval(goal.targetDuration - currentDisplayElapsedTime)) remaining")
                    .font(.appCaption)
                    .foregroundColor(.secondaryText)
            }
        }
        .appCardStyle()
    }
} 