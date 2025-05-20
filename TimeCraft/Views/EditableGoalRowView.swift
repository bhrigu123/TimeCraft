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
        HStack(spacing: 12) {
            // Color Dot and Color Picker
            Circle()
                .fill(goal.color)
                .frame(width: 20, height: 20)
                .onTapGesture {
                    showingColorPicker = true
                }
                .popover(isPresented: $showingColorPicker) {
                    ColorSwatchView(selectedColorHex: Binding(
                        get: { goal.colorHex },
                        set: { (newHex: String) in
                            var updatedGoal = goal
                            updatedGoal.colorHex = newHex
                            // It's important that onSave is called to persist the change
                            // and ensure the @Binding goal reflects the update immediately
                            // if the source of truth relies on it.
                            onSave(updatedGoal)
                        }
                    ), onColorSelected: { selectedHex in
                        // This callback is used by ColorSwatchView to update the binding.
                        // The actual save logic is now within the binding's setter above.
                        // If you want to dismiss the popover upon selection, 
                        // you can call showingColorPicker = false here or inside ColorSwatchView.
                        // For now, relying on the "Done" button in ColorSwatchView.
                    })
                }

            // Goal Name (Text or TextField)
            if isEditingName {
                TextField("Goal Name", text: $editingName, onCommit: {
                    var updatedGoal = goal
                    updatedGoal.name = editingName
                    onSave(updatedGoal)
                    isEditingName = false
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    var updatedGoal = goal
                    updatedGoal.name = editingName
                    onSave(updatedGoal)
                    isEditingName = false
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
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

            Spacer()
            
            // Target Duration (Text, and Picker for editing)
            Text("Goal: \(formatTimeInterval(goal.targetDuration))")
                .font(.appCaption)
                .foregroundColor(.secondaryText)
                .onTapGesture {
                    let components = durationComponents(from: goal.targetDuration)
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

            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.destructiveAction)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 6)
        .onAppear {
            // Initialize editingName if goal name changes from outside
            // This might not be strictly necessary if using @Binding correctly throughout
            editingName = goal.name
        }
    }

    // Removed local helper functions as they are now global in TimeFormatting.swift
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