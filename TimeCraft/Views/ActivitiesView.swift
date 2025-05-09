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