import SwiftUI
import Combine

class ActivityTimerService: ObservableObject {
    @AppStorage("activities") private var activitiesData: Data = Data()

    @Published var activeActivityID: UUID? = nil
    @Published var currentElapsedTimeForActiveActivity: TimeInterval = 0
    
    private var timer: Timer? = nil
    private var cancellables = Set<AnyCancellable>()

    // To load activities from AppStorage
    private var activities: [Activity] {
        get {
            (try? JSONDecoder().decode([Activity].self, from: activitiesData)) ?? []
        }
        set {
            if let encodedActivities = try? JSONEncoder().encode(newValue) {
                activitiesData = encodedActivities
            } else {
                print("Error encoding activities in TimerService")
            }
        }
    }

    init() {
        // Potentially load last active timer state if app was quit while timer was running
        // For now, we start fresh.
    }

    func activity(with id: UUID) -> Activity? {
        activities.first(where: { $0.id == id })
    }

    func startTimer(for activityID: UUID) {
        guard let activityToStart = activity(with: activityID) else { return }

        if let currentActiveID = activeActivityID, currentActiveID != activityID {
            // Stop any existing timer for a different activity
            stopAndSaveCurrentTimer()
        }
        
        activeActivityID = activityID
        currentElapsedTimeForActiveActivity = activityToStart.elapsedTime

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentElapsedTimeForActiveActivity += 1
            // Optionally, update the main activities array periodically or only on stop
        }
    }

    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        // Save current progress when pausing
        if let currentActiveID = activeActivityID {
            updateActivityElapsedTime(activityID: currentActiveID, newTime: currentElapsedTimeForActiveActivity)
        }
        activeActivityID = nil // Reset activeActivityID to nil when pausing
        // To make the card show 'play' again. If resume is needed, this needs more state.
    }

    func stopAndSaveCurrentTimer() {
        timer?.invalidate()
        timer = nil
        if let currentActiveID = activeActivityID {
            updateActivityElapsedTime(activityID: currentActiveID, newTime: currentElapsedTimeForActiveActivity)
        }
        activeActivityID = nil
        currentElapsedTimeForActiveActivity = 0
    }
    
    private func updateActivityElapsedTime(activityID: UUID, newTime: TimeInterval) {
        var updatedActivities = self.activities
        if let index = updatedActivities.firstIndex(where: { $0.id == activityID }) {
            updatedActivities[index].elapsedTime = newTime
            self.activities = updatedActivities // This triggers the setter which saves to AppStorage
        } else {
            print("Error: Tried to update non-existent activity")
        }
    }
    
    // Call this when the app is about to terminate to ensure progress is saved
    func saveCurrentStateBeforeQuit() {
        if activeActivityID != nil {
            stopAndSaveCurrentTimer()
        }
    }
} 