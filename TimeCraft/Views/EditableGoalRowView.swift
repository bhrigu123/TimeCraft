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
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
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
                                .focused($isTextFieldFocused)
                                .onSubmit {
                                    saveNameChange()
                                }
                            
                            Button(action: saveNameChange) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(.plain)
                            .transition(.opacity)
                        }
                    } else {
                        Text(goal.name)
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(.primaryText)
                            .onTapGesture {
                                editingName = goal.name
                                isEditingName = true
                                // Focus the text field after a brief delay to ensure the view has updated
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isTextFieldFocused = true
                                }
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
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider()
                .padding(.leading)
        }
        .onChange(of: isEditingName) { editing in
            if !editing {
                isTextFieldFocused = false
            }
        }
        .popover(isPresented: $showingDurationPicker) {
            VStack(spacing: 16) {
                HStack(spacing: 24) {
                    VStack {
                        Text("Hours").font(.caption)
                        Picker("", selection: $editingHours) {
                            ForEach(0..<24) { hour in
                                Text("\(hour)h").tag(hour)
                            }
                        }
                        .frame(width: 80)
                        .labelsHidden()

                    }
                    
                    VStack {
                        Text("Minutes").font(.caption)
                        Picker("", selection: $editingMinutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute)m").tag(minute)
                            }
                        }
                        .frame(width: 80)
                        .labelsHidden()
                    }
                }
                
                Button("Set Duration") {
                    var updatedGoal = goal
                    updatedGoal.targetDuration = TimeInterval((editingHours * 3600) + (editingMinutes * 60))
                    onSave(updatedGoal)
                    showingDurationPicker = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .frame(minWidth: 240)
        }
    }
    
    private func saveNameChange() {
        var updatedGoal = goal
        updatedGoal.name = editingName
        onSave(updatedGoal)
        isEditingName = false
    }
}

// Preview
struct EditableGoalRowView_Previews: PreviewProvider {
    static var previews: some View {
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