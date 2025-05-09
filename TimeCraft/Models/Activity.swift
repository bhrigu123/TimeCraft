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
