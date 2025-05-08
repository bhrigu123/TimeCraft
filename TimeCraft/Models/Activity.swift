import SwiftUI

struct Activity: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var targetDuration: TimeInterval // in seconds
    var elapsedTime: TimeInterval = 0 // in seconds
    var colorHex: String
    var iconName: String

    // Computed property to get SwiftUI Color from hex string
    // This will now use the Color(hex:) extension defined in Theme.swift
    var color: Color {
        Color(hex: colorHex) ?? .blue // Fallback to blue if hex is invalid
    }
}

// The Color(hex:) extension is now defined in Theme.swift to avoid duplication.
// extension Color {
//     init?(hex: String) {
//         var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//         hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
// 
//         var rgb: UInt64 = 0
// 
//         guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
//             return nil
//         }
// 
//         let red = Double((rgb & 0xFF0000) >> 16) / 255.0
//         let green = Double((rgb & 0x00FF00) >> 8) / 255.0
//         let blue = Double(rgb & 0x0000FF) / 255.0
// 
//         self.init(red: red, green: green, blue: blue)
//     }
// } 