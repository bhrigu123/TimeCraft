import SwiftUI
import Combine
import os.log
import AppKit

class GoalTimerService: ObservableObject {
    private let logger = Logger(subsystem: "com.timecraft", category: "GoalTimerService")
    @AppStorage("goals") private var goalsData: Data = Data()
    @Published private(set) var goals: [Goal] = []

    @Published var activeGoalID: UUID? = nil
    @Published var currentElapsedTimeForActiveGoal: TimeInterval = 0
    
    private var timer: Timer? = nil
    private var cancellables = Set<AnyCancellable>()
    private var lastSaveTime: Date = Date()
    private let saveInterval: TimeInterval = 60.0 // Save every 60 seconds
    private var workspace = NSWorkspace.shared
    private var distributedCenter = DistributedNotificationCenter.default()

    init() {
        loadGoals()
        checkAndResetForNewDay()
        setupNotificationObservers()
    }
    
    private func loadGoals() {
        do {
            if goalsData.isEmpty {
                logger.info("No goals data found in storage")
                goals = []
                return
            }
            
            let decodedGoals = try JSONDecoder().decode([Goal].self, from: goalsData)
            logger.info("Successfully loaded \(decodedGoals.count) goals from storage")
            DispatchQueue.main.async { [weak self] in
                self?.goals = decodedGoals
            }
        } catch {
            logger.error("Failed to decode goals: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.goals = []
            }
        }
    }
    
    func saveGoals(_ updatedGoals: [Goal]) {
        do {
            let encodedGoals = try JSONEncoder().encode(updatedGoals)
            goalsData = encodedGoals
            logger.info("Successfully saved \(updatedGoals.count) goals to storage")
            
            // Update the published property on the main queue
            DispatchQueue.main.async { [weak self] in
                self?.goals = updatedGoals
            }
        } catch {
            logger.error("Failed to encode goals: \(error.localizedDescription)")
        }
    }
    
    private func checkAndResetForNewDay() {
        var updatedGoals = self.goals
        var needsSave = false
        
        for i in 0..<updatedGoals.count {
            updatedGoals[i].checkAndResetForNewDay()
            needsSave = true // Always save after checking for new day
        }
        
        if needsSave {
            saveGoals(updatedGoals)
        }
    }

    func goal(with id: UUID) -> Goal? {
        goals.first(where: { $0.id == id })
    }

    func startTimer(for goalID: UUID) {
        guard let goalToStart = goal(with: goalID) else {
            logger.error("Attempted to start timer for non-existent goal: \(goalID)")
            return
        }

        if let currentActiveID = activeGoalID, currentActiveID != goalID {
            // Stop any existing timer for a different goal
            stopTimer()
        }
        
        activeGoalID = goalID
        currentElapsedTimeForActiveGoal = goalToStart.todayProgress
        lastSaveTime = Date()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentElapsedTimeForActiveGoal += 1
            
            // Update the goal's daily progress in memory
            if let currentActiveID = self.activeGoalID {
                self.updateGoalDailyProgressInMemory(goalID: currentActiveID, newTime: self.currentElapsedTimeForActiveGoal)
                
                // Save to storage periodically
                let now = Date()
                if now.timeIntervalSince(self.lastSaveTime) >= self.saveInterval {
                    self.saveActiveGoalProgress()
                    self.lastSaveTime = now
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        // Save current progress when stopping
        if let currentActiveID = activeGoalID {
            saveActiveGoalProgress()
        }
        activeGoalID = nil
        currentElapsedTimeForActiveGoal = 0
    }
    
    private func updateGoalDailyProgressInMemory(goalID: UUID, newTime: TimeInterval) {
        if let index = goals.firstIndex(where: { $0.id == goalID }) {
            goals[index].updateTodayProgress(newTime)
        }
    }
    
    private func saveActiveGoalProgress() {
        guard let activeID = activeGoalID else { return }
        
        var updatedGoals = self.goals
        if let index = updatedGoals.firstIndex(where: { $0.id == activeID }) {
            updatedGoals[index].updateTodayProgress(currentElapsedTimeForActiveGoal)
            saveGoals(updatedGoals)
            logger.info("Saved progress for active goal: \(activeID)")
        }
    }
    
    func createNewGoal(name: String = "New Goal", targetDuration: TimeInterval = 3600) {
        // Get a random color from predefined colors
        let randomColorGoal = Color.predefinedGoalColors.randomElement() ?? Color.predefinedGoalColors[0]
        
        let newGoal = Goal(
            name: name,
            targetDuration: targetDuration,
            colorHex: randomColorGoal.hex,
            iconName: "list.star" // Default icon
        )
        
        // Add the new goal at the beginning of the array
        var updatedGoals = self.goals
        updatedGoals.insert(newGoal, at: 0)
        saveGoals(updatedGoals)
        logger.info("Created new goal: \(name)")
    }
    
    func reorderGoals(from source: IndexSet, to destination: Int) {
        var updatedGoals = self.goals
        updatedGoals.move(fromOffsets: source, toOffset: destination)
        saveGoals(updatedGoals)
        logger.info("Reordered goals: moved from \(source) to \(destination)")
    }
    
    @objc func saveCurrentStateAndStopTimer() {
        logger.info("Saving current state and stopping timer")
        if activeGoalID != nil {
            stopTimer()
        }
    }

    private func setupNotificationObservers() {
        // App-internal notifications
        let notificationCenter = NotificationCenter.default
        
        // UserDefaults changes
        notificationCenter.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.loadGoals()
            }
            .store(in: &cancellables)
        
        // App termination
        notificationCenter.addObserver(
            self,
            selector: #selector(saveCurrentStateAndStopTimer),
            name: NSApplication.willTerminateNotification,
            object: nil
        )
        
        // Workspace notifications (current user session)
        let workspaceNotifications: [NSNotification.Name] = [
            NSWorkspace.willSleepNotification,          // System sleep
            NSWorkspace.screensDidSleepNotification,    // Display sleep
            NSWorkspace.sessionDidResignActiveNotification  // User session change
        ]
        
        workspaceNotifications.forEach { notification in
            workspace.notificationCenter.addObserver(
                self,
                selector: #selector(saveCurrentStateAndStopTimer),
                name: notification,
                object: nil
            )
        }
        
        // System-wide notifications
        let systemNotifications: [NSNotification.Name] = [
            NSNotification.Name("com.apple.screensaver.didstart"),  // Screen saver
            NSNotification.Name("com.apple.screenIsLocked")         // Screen lock
        ]
        
        systemNotifications.forEach { notification in
            distributedCenter.addObserver(
                self,
                selector: #selector(saveCurrentStateAndStopTimer),
                name: notification,
                object: nil
            )
        }
    }
} 