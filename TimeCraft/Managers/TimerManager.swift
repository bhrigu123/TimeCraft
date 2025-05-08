import Foundation
import Combine

// Manages the state and logic for the timer functionality.
// This class is an ObservableObject, allowing SwiftUI views to subscribe to its changes.
class TimerManager: ObservableObject {
    // Published properties will notify subscribing views of any changes.
    @Published var secondsElapsed = 0       // The total number of seconds elapsed on the timer.
    @Published var timerMode: TimerMode = .stopped // The current mode of the timer (e.g., running, stopped).

    var timer: Timer? // The underlying Timer instance from the Foundation framework.

    // Enum to represent the different states the timer can be in.
    enum TimerMode {
        case running
        case stopped
        // case paused // A potential state for future pause functionality.
    }

    // Starts the timer.
    // If the timer is already running, this function does nothing.
    func startTimer() {
        guard timerMode == .stopped else { return } // Only start if currently stopped.
        secondsElapsed = 0 // Reset seconds when starting a new session.
        timerMode = .running
        // Schedule a new timer that fires every 1 second.
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.secondsElapsed += 1 // Increment seconds elapsed.
        }
    }

    // Stops the currently running timer.
    func stopTimer() {
        timer?.invalidate() // Stop the timer from firing.
        timer = nil         // Release the timer instance.
        timerMode = .stopped
        // Optionally, you could reset secondsElapsed here if desired when stopping:
        // secondsElapsed = 0
    }

    // Resets the timer to its initial state.
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        secondsElapsed = 0
        timerMode = .stopped
    }
    
    // Formats the total secondsElapsed into a HH:MM:SS string representation.
    func formattedTime() -> String {
        let hours = secondsElapsed / 3600
        let minutes = (secondsElapsed % 3600) / 60
        let seconds = secondsElapsed % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
} 