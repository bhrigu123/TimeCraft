import SwiftUI

struct ColorSwatchView: View {
    @Binding var selectedColorHex: String
    let colors: [ActivityColor] = Color.predefinedActivityColors
    let onColorSelected: (String) -> Void
    @Environment(\.dismiss) var dismiss

    // Define the grid layout: 5 columns
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)

    var body: some View {
        VStack(spacing: 15) {
            Text("Select a Color")
                .font(.appHeadline)
                .padding(.top)

            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(colors, id: \.hex) { activityColor in
                    Circle()
                        .fill(activityColor.color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(0.5), lineWidth: selectedColorHex == activityColor.hex ? 3 : 0)
                        )
                        .padding(2) // Padding to make the stroke more visible if it's at the edge
                        .onTapGesture {
                            selectedColorHex = activityColor.hex
                            onColorSelected(activityColor.hex)
                            // Optional: dismiss after selection
                            // dismiss()
                        }
                }
            }
            
            Button("Done") {
                dismiss()
            }
            .padding(.top)
            .keyboardShortcut(.defaultAction) // Allows Enter key to dismiss
        }
        .padding()
        .frame(minWidth: 250, idealWidth: 300, minHeight: 180)
    }
}

struct ColorSwatchView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample binding for preview
        @State var previewSelectedHex = Color.predefinedActivityColors[3].hex // Gold
        
        ColorSwatchView(selectedColorHex: $previewSelectedHex, onColorSelected: { hex in
            print("Preview: Color selected: \(hex)")
        })
    }
} 