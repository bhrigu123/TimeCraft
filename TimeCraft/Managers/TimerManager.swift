import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var secondsElapsed = 0
    @Published var timerMode: TimerMode = .stopped

    var timer: Timer?

    enum TimerMode {
        case running
        case stopped
        case paused // For future use if needed
    }

    func startTimer() {
        guard timerMode == .stopped else { return }
        secondsElapsed = 0
        timerMode = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.secondsElapsed += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerMode = .stopped
        // secondsElapsed = 0 // Optionally reset here or keep the value
    }

    func resetTimer() {
        timer?.invalidate()
        timer = nil
        secondsElapsed = 0
        timerMode = .stopped
    }
    
    // func pauseTimer() { // For future use
    //     timer?.invalidate()
    //     timerMode = .paused
    // }

    func formattedTime() -> String {
        let hours = secondsElapsed / 3600
        let minutes = (secondsElapsed % 3600) / 60
        let seconds = secondsElapsed % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
} 