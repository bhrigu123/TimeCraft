import SwiftUI

// MARK: - Color Palette
extension Color {
    // General UI Colors
    static let appBackground = Color(NSColor.controlBackgroundColor)
    static let secondaryBackground = Color(hex: "#E9E9EB")!
    static let cardBackground = Color(NSColor.windowBackgroundColor)
    
    // Text Colors
    static let primaryText = Color(NSColor.labelColor)
    static let secondaryText = Color(NSColor.secondaryLabelColor)

    // Accent and Interactive Colors
    static let appAccent = Color(hex: "#007AFF")!
    static let destructiveAction = Color(hex: "#FF3B30")!

    // Activity Specific Colors (examples, can be expanded or kept in Activity model)
    static let deepWorkColor = Color(hex: "#5E5CE6")!
    static let readingColor = Color(hex: "#BF5AF2")!
    static let exerciseColor = Color(hex: "#32ADE6")!
    
    // Add more colors as needed, e.g., for icons, borders, etc.
}

// MARK: - Predefined Goal Colors
struct GoalColor: Identifiable, Hashable {
    let id = UUID()
    let color: Color
    let hex: String
}

extension Color {
    static let predefinedGoalColors: [GoalColor] = [
        // Row 1
        GoalColor(color: Color(hex: "#555555")!, hex: "#555555"), // Dark Gray
        GoalColor(color: Color(hex: "#AAAAAA")!, hex: "#AAAAAA"), // Light Gray
        GoalColor(color: Color(hex: "#A0522D")!, hex: "#A0522D"), // Brown (Sienna)
        GoalColor(color: Color(hex: "#FFD700")!, hex: "#FFD700"), // Gold
        GoalColor(color: Color(hex: "#FFA500")!, hex: "#FFA500"), // Orange
        // Row 2
        GoalColor(color: Color(hex: "#2E8B57")!, hex: "#2E8B57"), // Green (SeaGreen)
        GoalColor(color: Color(hex: "#4682B4")!, hex: "#4682B4"), // Blue (SteelBlue)
        GoalColor(color: Color(hex: "#8A2BE2")!, hex: "#8A2BE2"), // Purple (BlueViolet)
        GoalColor(color: Color(hex: "#FF69B4")!, hex: "#FF69B4"), // Pink (HotPink)
        GoalColor(color: Color(hex: "#DC143C")!, hex: "#DC143C")  // Red (Crimson)
    ]
}

// MARK: - Font Styles (Placeholder - can be expanded)
extension Font {
    static func appFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    static let appHeadline = appFont(size: 17, weight: .semibold)
    static let appSubheadline = appFont(size: 15, weight: .regular)
    static let appBody = appFont(size: 17, weight: .regular)
    static let appCaption = appFont(size: 12, weight: .regular)
    static let appButton = appFont(size: 16, weight: .medium)
}

// MARK: - Reusable ViewModifiers (Example - Card Style)
struct CardStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

extension View {
    func appCardStyle() -> some View {
        self.modifier(CardStyleModifier())
    }
}

// MARK: - Color Hex Initializer
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    // Instance method to convert Color to Hex String
    func toHex() -> String? {
        guard let cgColor = self.cgColor else {
            #if os(macOS)
            // On macOS, NSColor needs to be converted to CGColor via a compatible color space.
            // This is a simplified handling; a more robust solution might be needed
            // depending on the color spaces used in your app.
            guard let nsColor = NSColor(self).usingColorSpace(.sRGB) else { return nil}
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0 // Alpha is not used in the hex string but fetched
            nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return String(format: "#%02lX%02lX%02lX", 
                          lround(Double(red * 255)), 
                          lround(Double(green * 255)), 
                          lround(Double(blue * 255)))
            #else
            // For iOS, watchOS, tvOS, .cgColor should typically work directly if color is convertible.
            return nil
            #endif
        }
        
        let components = cgColor.components
        guard let r = components?[0], let g = components?[1], let b = components?[2] else {
            // This case can happen if the color space doesn't have RGB components (e.g. grayscale)
            // Or if components array is unexpectedly short.
            // A more robust solution might try to convert to an RGB color space first.
            return nil // Or handle appropriately
        }
        
        return String(format: "#%02lX%02lX%02lX", 
                      lround(Double(r * 255)), 
                      lround(Double(g * 255)), 
                      lround(Double(b * 255)))
    }
} 