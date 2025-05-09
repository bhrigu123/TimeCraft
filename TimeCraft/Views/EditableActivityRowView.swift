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
                    ColorSwatchView(selectedColorHex: Binding(
                        get: { activity.colorHex },
                        set: { (newHex: String) in
                            var updatedActivity = activity
                            updatedActivity.colorHex = newHex
                            // It's important that onSave is called to persist the change
                            // and ensure the @Binding activity reflects the update immediately
                            // if the source of truth relies on it.
                            onSave(updatedActivity)
                        }
                    ), onColorSelected: { selectedHex in
                        // This callback is used by ColorSwatchView to update the binding.
                        // The actual save logic is now within the binding's setter above.
                        // If you want to dismiss the popover upon selection, 
                        // you can call showingColorPicker = false here or inside ColorSwatchView.
                        // For now, relying on the "Done" button in ColorSwatchView.
                    })
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

    // Removed local helper functions as they are now global in TimeFormatting.swift
}

// Helper extension for Color toHex is removed as it should be in a central place.
// Removed: // extension Color { ... }

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