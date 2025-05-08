import SwiftUI

struct AddActivityView: View {
    @Environment(\.dismiss) var dismiss

    // State for the activity details
    @State private var id: UUID? // To keep track of existing ID if editing
    @State private var name: String = ""
    @State private var targetHours: Int = 1
    @State private var targetMinutes: Int = 0
    @State private var selectedColor: Color = .blue
    @State private var iconName: String = "circle.fill"

    // Activity to edit (optional)
    let activityToEdit: Activity?

    // Callback to pass the saved activity (new or updated) to the parent view
    var onSave: (Activity) -> Void

    // Initializer to pre-fill form if editing
    init(activityToEdit: Activity? = nil, onSave: @escaping (Activity) -> Void) {
        self.activityToEdit = activityToEdit
        self.onSave = onSave

        if let activity = activityToEdit {
            _id = State(initialValue: activity.id)
            _name = State(initialValue: activity.name)
            _targetHours = State(initialValue: Int(activity.targetDuration / 3600))
            _targetMinutes = State(initialValue: Int((activity.targetDuration.truncatingRemainder(dividingBy: 3600)) / 60))
            _selectedColor = State(initialValue: activity.color) // Assuming Activity.color is SwiftUI.Color
            _iconName = State(initialValue: activity.iconName)
        } else {
            // Default values are already set by @State declarations for new activity
        }
    }

    private var targetDurationInSeconds: TimeInterval {
        TimeInterval((targetHours * 3600) + (targetMinutes * 60))
    }

    // Helper to convert SwiftUI Color to Hex String (simplified)
    // For a more robust solution, a dedicated Color extension or utility is better.
    private func hexString(from color: Color) -> String {
        let components = color.cgColor?.components
        let r: CGFloat = components?[0] ?? 0
        let g: CGFloat = components?[1] ?? 0
        let b: CGFloat = components?[2] ?? 0
        return String(format: "#%02lX%02lX%02lX", lround(Double(r * 255)), lround(Double(g * 255)), lround(Double(b * 255)))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    TextField("Activity Name", text: $name)
                    
                    VStack(alignment: .leading) {
                        Text("Target Duration")
                        HStack {
                            Picker("Hours", selection: $targetHours) {
                                ForEach(0..<24) { Text("\($0)h").tag($0) }
                            }.pickerStyle(MenuPickerStyle())
                            Picker("Minutes", selection: $targetMinutes) {
                                ForEach(0..<60) { Text("\($0)m").tag($0) }
                            }.pickerStyle(MenuPickerStyle())
                        }
                    }
                    
                    ColorPicker("Activity Color", selection: $selectedColor)
                    
                    HStack {
                        Text("Icon Name (SF Symbol)")
                        TextField("e.g., book.fill", text: $iconName).multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle(activityToEdit == nil ? "Add New Activity" : "Edit Activity")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let finalID = activityToEdit?.id ?? UUID()
                        let originalElapsedTime = activityToEdit?.elapsedTime ?? 0
                        
                        let savedActivity = Activity(
                            id: finalID,
                            name: name,
                            targetDuration: targetDurationInSeconds,
                            elapsedTime: originalElapsedTime,
                            colorHex: hexString(from: selectedColor),
                            iconName: iconName.isEmpty ? "circle.fill" : iconName
                        )
                        onSave(savedActivity)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .frame(minWidth: 300, idealWidth: 350, minHeight: 300, idealHeight: 380)
        }
    }
}

// Preview for AddActivityView
struct AddActivityView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview for adding a new activity
        AddActivityView(onSave: { activity in print("Preview (New): \(activity.name)") })
        
        // Preview for editing an existing activity (requires a sample Activity)
        let sampleActivity = Activity(name: "Sample Edit", targetDuration: 3600, colorHex: "#FF0000", iconName: "star.fill")
        AddActivityView(activityToEdit: sampleActivity, onSave: { activity in print("Preview (Edit): \(activity.name)") })
    }
} 