import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss

    // State for the goal details
    @State private var id: UUID? // To keep track of existing ID if editing
    @State private var name: String = ""
    @State private var targetHours: Int = 1
    @State private var targetMinutes: Int = 0
    @State private var selectedColor: Color = .blue
    @State private var iconName: String = "circle.fill"

    // Goal to edit (optional)
    let goalToEdit: Goal?

    // Callback to pass the saved goal (new or updated) to the parent view
    var onSave: (Goal) -> Void

    // Initializer to pre-fill form if editing
    init(goalToEdit: Goal? = nil, onSave: @escaping (Goal) -> Void) {
        self.goalToEdit = goalToEdit
        self.onSave = onSave

        if let goal = goalToEdit {
            _id = State(initialValue: goal.id)
            _name = State(initialValue: goal.name)
            _targetHours = State(initialValue: Int(goal.targetDuration / 3600))
            _targetMinutes = State(initialValue: Int((goal.targetDuration.truncatingRemainder(dividingBy: 3600)) / 60))
            _selectedColor = State(initialValue: goal.color) // Assuming Goal.color is SwiftUI.Color
            _iconName = State(initialValue: goal.iconName)
        } else {
            // Default values are already set by @State declarations for new goal
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
                Section(header: Text("Goal Details")) {
                    TextField("Goal Name", text: $name)
                    
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
                    
                    ColorPicker("Goal Color", selection: $selectedColor)
                    
                    HStack {
                        Text("Icon Name (SF Symbol)")
                        TextField("e.g., book.fill", text: $iconName).multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle(goalToEdit == nil ? "Add New Goal" : "Edit Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let finalID = goalToEdit?.id ?? UUID()
                        let originalElapsedTime = goalToEdit?.elapsedTime ?? 0
                        
                        let savedGoal = Goal(
                            id: finalID,
                            name: name,
                            targetDuration: targetDurationInSeconds,
                            elapsedTime: originalElapsedTime,
                            colorHex: hexString(from: selectedColor),
                            iconName: iconName.isEmpty ? "circle.fill" : iconName
                        )
                        onSave(savedGoal)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .frame(minWidth: 300, idealWidth: 350, minHeight: 300, idealHeight: 380)
        }
    }
}

// Preview for AddGoalView
struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview for adding a new goal
        AddGoalView(onSave: { goal in print("Preview (New): \(goal.name)") })
        
        // Preview for editing an existing goal (requires a sample Goal)
        let sampleGoal = Goal(name: "Sample Edit", targetDuration: 3600, colorHex: "#FF0000", iconName: "star.fill")
        AddGoalView(goalToEdit: sampleGoal, onSave: { goal in print("Preview (Edit): \(goal.name)") })
    }
} 