import SwiftUI

struct EditableGoalRowView: View {
    @Binding var goal: Goal
    var onSave: (Goal) -> Void
    var onDelete: () -> Void

    @State private var isEditingName: Bool = false
    @State private var editingName: String = ""
    @State private var showingColorPicker: Bool = false
    @State private var showingDurationPicker: Bool = false
    @State private var editingHours: Int = 0
    @State private var editingMinutes: Int = 0
    
    var body: some View {
        HStack(spacing: 16) {
            // Color Dot and Color Picker
            Circle()
                .fill(goal.color)
                .frame(width: 24, height: 24)
                .onTapGesture {
                    showingColorPicker = true
                }
                .popover(isPresented: $showingColorPicker) {
                    ColorSwatchView(selectedColorHex: Binding(
                        get: { goal.colorHex },
                        set: { (newHex: String) in
                            var updatedGoal = goal
                            updatedGoal.colorHex = newHex
                            onSave(updatedGoal)
                        }
                    ), onColorSelected: { _ in })
                }

            VStack(alignment: .leading, spacing: 4) {
                // Goal Name (Text or TextField)
                if isEditingName {
                    HStack(spacing: 8) {
                        TextField("Goal Name", text: $editingName)
                            .font(.appFont(size: 16, weight: .medium))
                            .textFieldStyle(.plain)
                            .onSubmit {
                                saveNameChange()
                            }
                        
                        Button(action: saveNameChange) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Text(goal.name)
                        .font(.appFont(size: 16, weight: .medium))
                        .foregroundColor(.primaryText)
                        .onTapGesture {
                            editingName = goal.name
                            isEditingName = true
                        }
                }
                
                // Target Duration
                Text("Goal: \(formatTimeInterval(goal.targetDuration))")
                    .font(.appCaption)
                    .foregroundColor(.secondaryText)
                    .onTapGesture {
                        let components = durationComponents(from: goal.targetDuration)
                        editingHours = components.hours
                        editingMinutes = components.minutes
                        showingDurationPicker = true
                    }
            }

            Spacer()
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.destructiveAction)
                    .opacity(0.7)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .popover(isPresented: $showingDurationPicker) {
            VStack {
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
                    var updatedGoal = goal
                    updatedGoal.targetDuration = TimeInterval((editingHours * 3600) + (editingMinutes * 60))
                    onSave(updatedGoal)
                    showingDurationPicker = false
                }
                .padding()
            }
            .padding()
            .frame(minWidth: 250)
        }
    }
    
    private func saveNameChange() {
        var updatedGoal = goal
        updatedGoal.name = editingName
        onSave(updatedGoal)
        isEditingName = false
    }
}

// Helper extension for Color toHex is removed as it should be in a central place.
// Removed: // extension Color { ... }

// Preview
struct EditableGoalRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample goal binding for the preview
        @State var sampleGoal = Goal(
            name: "Deep Work",
            targetDuration: 2 * 3600,
            elapsedTime: 30 * 60,
            colorHex: Color.deepWorkColor.toHex() ?? "#5E5CE6",
            iconName: "brain.head.profile"
        )

        EditableGoalRowView(goal: $sampleGoal, onSave: { updatedGoal in
            print("Preview: Save \(updatedGoal.name)")
        }, onDelete: {
            print("Preview: Delete goal")
        })
        .padding()
        .background(Color.appBackground)
    }
} 