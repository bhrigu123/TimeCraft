import SwiftUI

struct SettingsView: View {
    // Use AppStorage to persist activities. They need to be Codable.
    @AppStorage("activities") private var activitiesData: Data = Data()
    
    // This computed property will encode/decode the activities array to/from Data
    private var activities: [Activity] {
        get {
            if let decodedActivities = try? JSONDecoder().decode([Activity].self, from: activitiesData) {
                return decodedActivities
            } else {
                // Return default activities if decoding fails or no data stored
                return [
                    Activity(name: "Deep Work", targetDuration: 2 * 3600, colorHex: "#5E5CE6", iconName: "moon.fill"),
                    Activity(name: "Reading", targetDuration: 1 * 3600, colorHex: "#BF5AF2", iconName: "book.fill"),
                    Activity(name: "Exercise", targetDuration: 45 * 60, colorHex: "#32ADE6", iconName: "figure.walk")
                ]
            }
        }
        set {
            if let encodedActivities = try? JSONEncoder().encode(newValue) {
                activitiesData = encodedActivities
            } else {
                // Handle encoding error, perhaps log it or show an alert
                print("Error encoding activities")
            }
        }
    }

    @State private var showingAddActivitySheet = false

    // We need a way to trigger a save when activities array is modified through bindings or direct manipulation
    // This is a workaround for direct modification of the 'activities' computed property not always triggering AppStorage update immediately.
    // For robust state management with complex types and AppStorage, an ObservableObject is often better.
    // For now, we will explicitly call a save function after modifications.
    private func saveActivities(_ newActivities: [Activity]) {
        if let encodedActivities = try? JSONEncoder().encode(newActivities) {
            activitiesData = encodedActivities
        } else {
            print("Error encoding activities for save")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Activities count and Add button
            HStack {
                Text("Activities (\(activities.count))")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showingAddActivitySheet = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Activity")
                    }
                }
            }
            .padding()

            // List of activities
            List {
                ForEach(activities) { activity in // This now uses the computed property
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(activity.color)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(activity.name)
                                .font(.title3)
                            Text("Daily goal: \(formatTimeInterval(activity.targetDuration))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { /* Edit action - will need to update activities array and save */ }) {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        Button(action: { 
                            var updatedActivities = activities // Get a mutable copy
                            if let index = updatedActivities.firstIndex(where: { $0.id == activity.id }) {
                                updatedActivities.remove(at: index)
                                saveActivities(updatedActivities) // Explicitly save
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(InsetListStyle())
            
            Spacer()

            // Footer
            HStack {
                Button(action: { /* Reset progress action - will need to update activities array and save */ }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Progress")
                    }
                }
                Spacer()
                Text("v1.0.0")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .sheet(isPresented: $showingAddActivitySheet) {
            // Placeholder for AddActivityView
            // Pass a binding or callback to add a new activity and save
            Text("Add New Activity Sheet") 
            // Example: AddActivityView(activities: $activities) where activities is now a binding to the property that handles get/set with save.
            // For direct use with AppStorage and complex types, it's often better to wrap AppStorage in an ObservableObject.
            // For now, the sheet will need a mechanism to update the source `activities` array and trigger a save.
        }
    }

    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? ""
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .frame(width: 320, height: 450)
    }
} 