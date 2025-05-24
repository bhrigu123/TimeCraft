import SwiftUI

struct Goal: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var targetDuration: TimeInterval // in seconds
    var elapsedTime: TimeInterval = 0 // in seconds
    var colorHex: String
    var iconName: String // Not being used right now
    
    // Store daily progress with date as key (YYYY-MM-DD format)
    var dailyProgress: [String: TimeInterval] = [:]
    
    // Track the last date this goal was reset
    var lastResetDate: String = Calendar.current.startOfDay(for: Date()).formatted(date: .numeric, time: .omitted)
    
    // Computed property to get today's progress
    var todayProgress: TimeInterval {
        let today = Calendar.current.startOfDay(for: Date()).formatted(date: .numeric, time: .omitted)
        return dailyProgress[today] ?? 0
    }
    
    // Computed property to get total progress (sum of all days)
    var totalProgress: TimeInterval {
        dailyProgress.values.reduce(0, +)
    }

    // Computed property to get SwiftUI Color from hex string
    var color: Color {
        Color(hex: colorHex) ?? .blue // Fallback to blue if hex is invalid
    }
    
    // Helper to update today's progress
    mutating func updateTodayProgress(_ newTime: TimeInterval) {
        let today = Calendar.current.startOfDay(for: Date()).formatted(date: .numeric, time: .omitted)
        dailyProgress[today] = newTime
    }
    
    // Helper to check if we need to reset for a new day
    mutating func checkAndResetForNewDay() {
        let today = Calendar.current.startOfDay(for: Date()).formatted(date: .numeric, time: .omitted)
        if lastResetDate != today {
            // It's a new day, reset the progress
            lastResetDate = today
            // We don't clear the dailyProgress dictionary to maintain history
        }
    }
} 