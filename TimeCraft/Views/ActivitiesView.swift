import SwiftUI

struct ActivitiesView: View {
    @AppStorage("activities") private var activitiesData: Data = Data()
    @ObservedObject var timerService: ActivityTimerService // Receive the timer service

    private var activities: [Activity] {
        // Decode activities, providing an empty array or default if necessary
        // Ensure this matches the decoding logic in SettingsView for consistency
        if let decodedActivities = try? JSONDecoder().decode([Activity].self, from: activitiesData) {
            return decodedActivities
        } else {
            // If SettingsView provides defaults, ActivitiesView might want to show empty or a message
            // For now, returning empty if no data, assuming SettingsView is the source of truth for creation
            return [] 
        }
    }

    var body: some View {
        if activities.isEmpty {
            VStack {
                Text("No Activities")
                    .font(.appHeadline) // Use themed font
                    .foregroundColor(.primaryText)
                Text("Go to Settings to add new activities.")
                    .font(.appSubheadline) // Use themed font
                    .foregroundColor(.secondaryText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground) // Apply here
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(activities) { activity in
                        // Pass the specific activity and the timer service to the card view
                        ActivityCardView(activity: activity, timerService: timerService)
                    }
                }
                .padding()
            }
            .background(Color.appBackground) // Apply here
        }
    }
}

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

    // Helper to format time interval (can be moved to a shared utility file later)
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        // Ensure non-negative intervals are formatted correctly
        let nonNegativeInterval = max(0, interval)
        return formatter.string(from: nonNegativeInterval) ?? "0m"
    }
}

struct ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock data for previewing ActivitiesView
        let sampleActivitiesData: () -> Data = {
            let activities = [
                Activity(name: "Deep Work", targetDuration: 2 * 3600, elapsedTime: 35 * 60, colorHex: "#5E5CE6", iconName: "moon.fill"),
                Activity(name: "Reading", targetDuration: 1 * 3600, elapsedTime: 15 * 60, colorHex: "#BF5AF2", iconName: "book.fill"),
                Activity(name: "Exercise", targetDuration: 45 * 60, elapsedTime: 0, colorHex: "#32ADE6", iconName: "figure.walk")
            ]
            return (try? JSONEncoder().encode(activities)) ?? Data()
        }
        
        // Create a mock timer service for the preview
        let mockTimerService = ActivityTimerService()

        ActivitiesView(timerService: mockTimerService)
            .onAppear {
                // For preview purposes, inject sample data into AppStorage
                UserDefaults.standard.setValue(sampleActivitiesData(), forKey: "activities")
            }
            .frame(width: 320, height: 450)
            .background(Color.appBackground) // Add background for preview context
    }
} 