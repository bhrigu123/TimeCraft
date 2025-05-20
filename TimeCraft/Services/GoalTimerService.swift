import SwiftUI
import Combine

class GoalTimerService: ObservableObject {
    @AppStorage("goals") private var goalsData: Data = Data()
    @Published private(set) var goals: [Goal] = []

    @Published var activeGoalID: UUID? = nil
    @Published var currentElapsedTimeForActiveGoal: TimeInterval = 0
    
    private var timer: Timer? = nil
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Load initial goals
        loadGoals()
        
        // Observe changes to goalsData
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.loadGoals()
            }
            .store(in: &cancellables)
            
        // Check for new day and reset if needed when app starts
        checkAndResetForNewDay()
    }
    
    private func loadGoals() {
        if let decodedGoals = try? JSONDecoder().decode([Goal].self, from: goalsData) {
            DispatchQueue.main.async { [weak self] in
                self?.goals = decodedGoals
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.goals = []
            }
        }
    }
    
    func saveGoals(_ updatedGoals: [Goal]) {
        if let encodedGoals = try? JSONEncoder().encode(updatedGoals) {
            goalsData = encodedGoals
            // Update the published property on the main queue
            DispatchQueue.main.async { [weak self] in
                self?.goals = updatedGoals
            }
        } else {
            print("Error encoding goals in TimerService")
        }
    }
    
    private func checkAndResetForNewDay() {
        var updatedGoals = self.goals
        for i in 0..<updatedGoals.count {
            updatedGoals[i].checkAndResetForNewDay()
        }
        saveGoals(updatedGoals)
    }

    func goal(with id: UUID) -> Goal? {
        goals.first(where: { $0.id == id })
    }

    func startTimer(for goalID: UUID) {
        guard let goalToStart = goal(with: goalID) else { return }

        if let currentActiveID = activeGoalID, currentActiveID != goalID {
            // Stop any existing timer for a different goal
            stopTimer()
        }
        
        activeGoalID = goalID
        currentElapsedTimeForActiveGoal = goalToStart.todayProgress

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentElapsedTimeForActiveGoal += 1
            // Update the goal's daily progress periodically
            if let currentActiveID = self.activeGoalID {
                self.updateGoalDailyProgress(goalID: currentActiveID, newTime: self.currentElapsedTimeForActiveGoal)
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        // Save current progress when stopping
        if let currentActiveID = activeGoalID {
            updateGoalDailyProgress(goalID: currentActiveID, newTime: currentElapsedTimeForActiveGoal)
        }
        activeGoalID = nil
        currentElapsedTimeForActiveGoal = 0
    }
    
    private func updateGoalDailyProgress(goalID: UUID, newTime: TimeInterval) {
        var updatedGoals = self.goals
        if let index = updatedGoals.firstIndex(where: { $0.id == goalID }) {
            updatedGoals[index].updateTodayProgress(newTime)
            saveGoals(updatedGoals)
        } else {
            print("Error: Tried to update non-existent goal")
        }
    }
    
    // Call this when the app is about to terminate to ensure progress is saved
    func saveCurrentStateBeforeQuit() {
        if activeGoalID != nil {
            stopTimer()
        }
    }
} 