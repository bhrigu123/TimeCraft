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
    
    private var progressPercentage: Double {
        let total = goal.targetDuration > 0 ? goal.targetDuration : 1
        return min(currentDisplayElapsedTime / total, 1.0)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack(alignment: .top) {
                    Text(goal.name)
                        .font(.appFont(size: 18, weight: .medium))
                        .foregroundColor(.primaryText)
                        .lineLimit(2)
                        .frame(height: 45, alignment: .leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Play/Pause button
                    Button(action: {
                        if isThisGoalActive {
                            timerService.stopTimer()
                        } else {
                            timerService.startTimer(for: goal.id)
                        }
                    }) {
                        Image(systemName: isThisGoalActive ? "pause.fill" : "play.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.appAccent)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }

                // Custom Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        Rectangle()
                            .fill(goal.color.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        // Progress bar
                        Rectangle()
                            .fill(goal.color)
                            .frame(width: geometry.size.width * progressPercentage, height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
                
                // Time details
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
            .padding(.horizontal)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Very translucent background using the goal's color
                    RoundedRectangle(cornerRadius: 16)
                        .fill(goal.color.opacity(0.08))
                    
                    // Active indicator on the leading edge
                    if isThisGoalActive {
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(goal.color)
                                .frame(width: 4)
                            Spacer()
                        }
                        .mask(
                            RoundedRectangle(cornerRadius: 16)
                        )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.bottom, 8)
    }
} 