import SwiftUI

struct Activity: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var targetDuration: TimeInterval // in seconds
    var elapsedTime: TimeInterval = 0 // in seconds
    var colorHex: String
    var iconName: String

    // Computed property to get SwiftUI Color from hex string
    var color: Color {
        Color(hex: colorHex) ?? .blue // Fallback to blue if hex is invalid
    }
}

// Dummy extension for Color to initialize from hex (a proper one might be more robust)
// This is a simplified version. For production, use a more robust hex color converter.
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
} 