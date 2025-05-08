import SwiftUI

struct EditableActivityRowView: View {
    @Binding var activity: Activity
    var onSave: (Activity) -> Void
    var onDelete: () -> Void

    @State private var isEditingName: Bool = false
    @State private var editingName: String = ""
    @State private var showingColorPicker: Bool = false
    @State private var showingDurationPicker: Bool = false
    @State private var editingHours: Int = 0
    @State private var editingMinutes: Int = 0
    
    // TODO: Add state for duration editing if needed, e.g., selectedHours, selectedMinutes

    var body: some View {
        HStack(spacing: 12) {
            // Color Dot and Color Picker
            Circle()
                .fill(activity.color)
                .frame(width: 20, height: 20)
                .onTapGesture {
                    showingColorPicker = true
                }
                .popover(isPresented: $showingColorPicker) {
                    VStack {
                        ColorPicker("Activity Color", selection: Binding(
                            get: { activity.color },
                            set: { newValue in
                                var updatedActivity = activity
                                updatedActivity.colorHex = newValue.toHex() ?? activity.colorHex
                                onSave(updatedActivity)
                            }
                        ), supportsOpacity: false)
                        Button("Done") {
                            showingColorPicker = false
                        }
                        .padding()
                    }
                    .padding()
                }

            // Activity Name (Text or TextField)
            if isEditingName {
                TextField("Activity Name", text: $editingName, onCommit: {
                    var updatedActivity = activity
                    updatedActivity.name = editingName
                    onSave(updatedActivity)
                    isEditingName = false
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    var updatedActivity = activity
                    updatedActivity.name = editingName
                    onSave(updatedActivity)
                    isEditingName = false
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            } else {
                Text(activity.name)
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(.primaryText)
                    .onTapGesture {
                        editingName = activity.name
                        isEditingName = true
                    }
            }

            Spacer()
            
            // Target Duration (Text, and Picker for editing)
            Text("Goal: \(formatTimeInterval(activity.targetDuration))")
                .font(.appCaption)
                .foregroundColor(.secondaryText)
                .onTapGesture {
                    let components = durationComponents(from: activity.targetDuration)
                    editingHours = components.hours
                    editingMinutes = components.minutes
                    showingDurationPicker = true
                }
                .popover(isPresented: $showingDurationPicker) {
                    VStack {
                        Text("Set Daily Goal").font(.headline).padding(.top)
                        HStack {
                            Picker("Hours", selection: $editingHours) {
                                ForEach(0..<24) { hour in
                                    Text("\(hour)h").tag(hour)
                                }
                            }
                            #if os(macOS)
                            .pickerStyle(MenuPickerStyle())
                            #else
                            .pickerStyle(WheelPickerStyle())
                            #endif
                            .frame(width: 100)
                            
                            Picker("Minutes", selection: $editingMinutes) {
                                ForEach(0..<60) { minute in
                                    Text("\(minute)m").tag(minute)
                                }
                            }
                            #if os(macOS)
                            .pickerStyle(MenuPickerStyle())
                            #else
                            .pickerStyle(WheelPickerStyle())
                            #endif
                            .frame(width: 100)
                        }
                        
                        Button("Set Duration") {
                            var updatedActivity = activity
                            updatedActivity.targetDuration = TimeInterval((editingHours * 3600) + (editingMinutes * 60))
                            onSave(updatedActivity)
                            showingDurationPicker = false
                        }
                        .padding()
                    }
                    .padding()
                    .frame(minWidth: 250)
                }

            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.destructiveAction)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 6)
        .onAppear {
            // Initialize editingName if activity name changes from outside
            // This might not be strictly necessary if using @Binding correctly throughout
            editingName = activity.name
        }
    }

    // Helper to format time interval (can be moved to a common utility file)
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        if interval == 0 {
            return "0m"
        }
        return formatter.string(from: interval) ?? "0m"
    }

    // Helper to break TimeInterval into hours and minutes for pickers
    private func durationComponents(from interval: TimeInterval) -> (hours: Int, minutes: Int) {
        let totalMinutes = Int(interval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return (hours, minutes)
    }
}

// Helper extension for Color toHex (should be in a central place like Theme.swift or Extensions.swift)
// This is added here temporarily to make EditableActivityRowView self-contained for now.
// Ensure this doesn't conflict with an existing global one.
// extension Color {
//     func toHex() -> String? {
//         guard let cgColor = self.cgColor else { return nil }
//         let components = cgColor.components
//         let r: CGFloat = components?[0] ?? 0
//         let g: CGFloat = components?[1] ?? 0
//         let b: CGFloat = components?[2] ?? 0
//         return String(format: "#%02lX%02lX%02lX", lround(Double(r * 255)), lround(Double(g * 255)), lround(Double(b * 255)))
//     }
// }

// Preview
struct EditableActivityRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample activity binding for the preview
        @State var sampleActivity = Activity(
            name: "Deep Work",
            targetDuration: 2 * 3600,
            elapsedTime: 30 * 60,
            colorHex: Color.deepWorkColor.toHex() ?? "#5E5CE6",
            iconName: "brain.head.profile"
        )

        EditableActivityRowView(activity: $sampleActivity, onSave: { updatedActivity in
            print("Preview: Save \(updatedActivity.name)")
        }, onDelete: {
            print("Preview: Delete activity")
        })
        .padding()
        .background(Color.appBackground)
    }
} 