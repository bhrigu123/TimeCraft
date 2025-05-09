import SwiftUI

struct ActivityCardView: View {
    // Use a non-optional Activity, ensure it's always passed correctly
    let activity: Activity 
    @ObservedObject var timerService: ActivityTimerService

    private var isThisActivityActive: Bool {
        timerService.activeActivityID == activity.id
    }

    private var currentDisplayElapsedTime: TimeInterval {
        isThisActivityActive ? timerService.currentElapsedTimeForActiveActivity : activity.elapsedTime
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(activity.name)
                    .font(.appFont(size: 20, weight: .semibold)) // Themed font
                    .foregroundColor(.primaryText)
                Spacer()
                Button(action: {
                    if isThisActivityActive {
                        timerService.pauseTimer()
                    } else {
                        timerService.startTimer(for: activity.id)
                    }
                }) {
                    Image(systemName: isThisActivityActive ? "pause.fill" : "play.fill")
                        .font(.appFont(size: 20, weight: .semibold)) // Match text size
                        .foregroundColor(.appAccent) // Use accent color
                }
                .buttonStyle(PlainButtonStyle())
            }

            ProgressView(value: currentDisplayElapsedTime, total: activity.targetDuration > 0 ? activity.targetDuration : 1)
                .progressViewStyle(LinearProgressViewStyle(tint: activity.color))

            HStack {
                Text("\(formatTimeInterval(currentDisplayElapsedTime)) spent")
                    .font(.appCaption) // Themed font
                    .foregroundColor(.secondaryText)
                Spacer()
                Text("\(formatTimeInterval(activity.targetDuration - currentDisplayElapsedTime)) remaining")
                    .font(.appCaption) // Themed font
                    .foregroundColor(.secondaryText)
            }
        }
        .appCardStyle() // Apply the reusable card style modifier
    }
} 