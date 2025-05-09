import Foundation

// Helper to format time interval into a string like "1h 30m"
func formatTimeInterval(_ interval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .abbreviated
    // Ensure non-negative intervals are formatted correctly
    let nonNegativeInterval = max(0, interval)
    return formatter.string(from: nonNegativeInterval) ?? "0m"
}

// Helper to break TimeInterval into hours and minutes components
func durationComponents(from interval: TimeInterval) -> (hours: Int, minutes: Int) {
    let totalMinutes = Int(interval) / 60
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    return (hours, minutes)
} 