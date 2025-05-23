import SwiftUI

struct ColorSwatchView: View {
    @Binding var selectedColorHex: String
    let colors: [GoalColor] = Color.predefinedGoalColors
    let onColorSelected: (String) -> Void
    @Environment(\.dismiss) var dismiss

    // Grid layout: 5 columns
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(colors, id: \.hex) { activityColor in
                Circle()
                    .fill(activityColor.color)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.5), lineWidth: selectedColorHex == activityColor.hex ? 3 : 0)
                    )
                    .padding(2) 
                    .onTapGesture {
                        selectedColorHex = activityColor.hex
                        onColorSelected(activityColor.hex)
                        dismiss()
                    }
            }
        }
        .padding()
        .frame(minWidth: 250, idealWidth: 300, minHeight: 120)
    }
}

struct ColorSwatchView_Previews: PreviewProvider {
    static var previews: some View {
        @State var previewSelectedHex = Color.predefinedGoalColors[3].hex 
        
        ColorSwatchView(selectedColorHex: $previewSelectedHex, onColorSelected: { hex in
            print("Preview: Color selected: \(hex)")
        })
    }
} 