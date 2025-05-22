import SwiftUI
import Combine
import AppKit

// The AppDelegate is responsible for managing application-level events and behaviors,
// particularly those not fully handled by the standard SwiftUI app lifecycle.
// For this menu bar app, it manages the NSStatusItem (the menu bar icon) and the NSPopover (the window that appears).
class AppDelegate: NSObject, NSApplicationDelegate {
    var iconItem: NSStatusItem?
    var textItem: NSStatusItem?
    var popover: NSPopover?
    var timerService: GoalTimerService? // Hold the timer service instance
    private var cancellables = Set<AnyCancellable>()

    // Called when the application has finished launching and is ready to run.
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the timer service instance
        let timerService = GoalTimerService()
        self.timerService = timerService

        // Create the icon status item with fixed width
        iconItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = iconItem?.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer")
            button.action = #selector(togglePopover(_:))
        }
        
        // Create the text status item (initially hidden)
        textItem = NSStatusBar.system.statusItem(withLength: 0)
        if let textButton = textItem?.button {
            // When text is clicked, show popover from the icon item
            textButton.action = #selector(togglePopover(_:))
        }

        // Create and configure the popover.
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 450) 
        popover?.behavior = .transient
        // Pass the timerService to ContentView
        popover?.contentViewController = NSHostingController(rootView: ContentView(timerService: timerService))

        // Subscribe to timer service changes
        setupTimerObservers(timerService)
    }

    private func setupTimerObservers(_ timerService: GoalTimerService) {
        // Combine active goal ID and elapsed time publishers
        Publishers.CombineLatest(timerService.$activeGoalID, timerService.$currentElapsedTimeForActiveGoal)
            .sink { [weak self] (goalID, elapsedTime) in
                self?.updateMenuBarText(goalID: goalID, elapsedTime: elapsedTime)
            }
            .store(in: &cancellables)
    }

    private func updateMenuBarText(goalID: UUID?, elapsedTime: TimeInterval) {
        guard let textButton = textItem?.button else { return }
        
        if let goalID = goalID, let goal = timerService?.goal(with: goalID) {
            // Format elapsed time
            let hours = Int(elapsedTime) / 3600
            let minutes = Int(elapsedTime) / 60 % 60
            let timeString = hours > 0 ? String(format: "%d:%02d", hours, minutes) : String(format: "%d min", minutes)
            
            // Truncate goal name if needed (max 15 chars)
            let truncatedName = goal.name.count > 15 ? 
                goal.name.prefix(12) + "..." : 
                goal.name
            
            // Show the text item and set its title
            textItem?.length = NSStatusItem.variableLength
            textButton.title = "\(truncatedName) (\(timeString))"
        } else {
            // Hide the text item when no goal is active
            textItem?.length = 0
            textButton.title = ""
        }
    }

    // This @objc function is called when the status item button (menu bar icon) is clicked.
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let popover = popover, let button = iconItem?.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            // Always show the popover relative to the icon item
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Save any active timer state before the app quits.
        timerService?.saveCurrentStateBeforeQuit()
    }
} 