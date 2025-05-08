import SwiftUI

struct SettingsView: View {
    // Use AppStorage to persist activities. They need to be Codable.
    @AppStorage("activities") private var activitiesData: Data = Data()
    @ObservedObject var timerService: ActivityTimerService // Receive the timer service
    
    // Computed property for activities, handles loading and default data
    private var activities: [Activity] {
        get {
            if activitiesData.isEmpty {
                return defaultActivities()
            }
            do {
                return try JSONDecoder().decode([Activity].self, from: activitiesData)
            } catch {
                print("Error: Could not decode activities data: \(error). Returning empty list.")
                return [] // Return empty or handle error appropriately
            }
        }
        set {
            saveActivities(newValue)
        }
    }

    // Method to provide default activities
    private func defaultActivities() -> [Activity] {
        let defaults = [
            Activity(name: "Deep Work", targetDuration: 2 * 3600, colorHex: Color.deepWorkColor.toHex() ?? "#5E5CE6", iconName: "moon.fill"),
            Activity(name: "Reading", targetDuration: 1 * 3600, colorHex: Color.readingColor.toHex() ?? "#BF5AF2", iconName: "book.fill"),
            Activity(name: "Exercise", targetDuration: 45 * 60, colorHex: Color.exerciseColor.toHex() ?? "#32ADE6", iconName: "figure.walk")
        ]
        // Persist defaults immediately if activitiesData was empty
        // This ensures that if the user interacts (e.g. edits) one of the defaults, the full list is saved.
        // The `activities` setter will handle the actual saving.
        // To trigger the save, we can assign to a temporary variable that then assigns to self.activities, or call saveActivities directly.
        // For simplicity, let's rely on the first modification via EditableActivityRowView to save them.
        // Or, we can explicitly save here if needed.
        // Note: Directly assigning to self.activities here would call the setter.
        // However, this function is called from the getter, which could lead to a loop.
        // The strategy will be: if activitiesData is empty, this provides defaults.
        // The first save operation triggered by an edit/delete will persist these defaults along with the change.
        return defaults
    }

    // Method to save activities to AppStorage
    private func saveActivities(_ updatedActivities: [Activity]) {
        do {
            let encodedActivities = try JSONEncoder().encode(updatedActivities)
            activitiesData = encodedActivities
        } catch {
            print("Error encoding activities for save: \(error)")
        }
    }
    
    private func resetAllProgress() {
        timerService.stopAndSaveCurrentTimer()
        var currentActivities = self.activities // Accesses the getter, which provides defaults if empty
        
        // If currentActivities is empty (meaning activitiesData was empty and defaults were provided by getter)
        // and we want to ensure these defaults are part of the reset, this structure is okay.
        // If activitiesData was empty, currentActivities will now hold the default activities.
        if currentActivities.isEmpty && activitiesData.isEmpty { // This condition might be redundant due to getter logic
             // The getter for `self.activities` already returns default activities if activitiesData is empty.
             // So, currentActivities will already be populated with defaults if needed.
             // If it's still empty, it means defaultActivities() returned empty, which shouldn't happen with current setup.
        }

        for i in 0..<currentActivities.count {
            currentActivities[i].elapsedTime = 0
        }
        // Use the setter for `activities` to save, or call `saveActivities` directly.
        // Calling saveActivities directly is clearer here.
        saveActivities(currentActivities)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Activities count
            // The "Add Activity" button is removed as per inline editing design.
            // User can be instructed to add activities through a different mechanism or we can add a dedicated "add row" later.
            HStack {
                Text("Activities (\(activities.count))")
                    .font(.appHeadline)
                    .foregroundColor(.primaryText)
                Spacer()
                Button(action: addNewActivity) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add New").font(.appButton) // Changed text slightly for brevity
                    }
                    .foregroundColor(.appAccent)
                }
            }
            .padding()

            // List of activities using EditableActivityRowView
            List {
                ForEach(activities.indices, id: \.self) { index in
                    EditableActivityRowView(
                        activity: Binding(
                            get: { self.activities[index] },
                            set: { (newValue) in
                                // This setter is called when any bound property inside EditableActivityRowView changes
                                var mutableActivities = self.activities
                                if mutableActivities.indices.contains(index) {
                                    mutableActivities[index] = newValue
                                    self.saveActivities(mutableActivities)
                                } else {
                                    print("Error: Index out of bounds while setting activity.")
                                }
                            }
                        ),
                        onSave: { activityToSave in
                            if let foundIndex = self.activities.firstIndex(where: { $0.id == activityToSave.id }) {
                                var mutableActivities = self.activities
                                mutableActivities[foundIndex] = activityToSave
                                self.saveActivities(mutableActivities)
                            } else {
                                print("Error: Activity to save not found in the list for onSave callback.")
                            }
                        },
                        onDelete: {
                            var currentActivities = self.activities
                            if currentActivities.indices.contains(index) {
                                let activityToDelete = currentActivities[index]
                                if timerService.activeActivityID == activityToDelete.id {
                                    timerService.stopAndSaveCurrentTimer()
                                }
                                currentActivities.remove(at: index)
                                self.saveActivities(currentActivities)
                            } else {
                                 print("Error: Index out of bounds for delete.")
                            }
                        }
                    )
                }
            }
            .listStyle(InsetListStyle())
            
            Spacer()

            // Footer
            HStack {
                Button(action: { resetAllProgress() }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Progress").font(.appButton)
                    }
                    .foregroundColor(.appAccent)
                }
                Spacer()
                Text("v1.0.0") // Consider making this dynamic from App Bundle
                    .font(.appCaption)
                    .foregroundColor(.secondaryText)
            }
            .padding()
        }
        .background(Color.appBackground.edgesIgnoringSafeArea(.all))
        // .sheet for AddActivityView is removed
    }

    private func addNewActivity() {
        let newActivity = Activity(
            name: "New Activity", 
            targetDuration: 3600, // Default to 1 hour
            colorHex: Color.gray.toHex() ?? "#8E8E93", // Default to a generic color
            iconName: "list.star" // Default icon
        )
        var updatedActivities = self.activities
        updatedActivities.append(newActivity)
        self.saveActivities(updatedActivities)
    }
}

// Color.toHex() extension is removed from here as it should be globally available (e.g., from Theme.swift or an extensions file)
// It was also in the original file, ensure it's defined once, centrally.

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock ActivityTimerService for the preview
        let mockTimerService = ActivityTimerService()
        
        // Example of populating AppStorage for preview if needed, or rely on defaults.
        // For a more robust preview, you might pre-populate activitiesData in AppStorage for the preview environment.
        SettingsView(timerService: mockTimerService)
            .frame(width: 350, height: 500) // Adjusted frame for better preview
    }
} 