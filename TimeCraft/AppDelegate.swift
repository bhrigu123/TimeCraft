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
    var timerService: GoalTimerService?
    private var cancellables = Set<AnyCancellable>()
    private var statusMenu: NSMenu?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let timerService = GoalTimerService()
        self.timerService = timerService

        // Menu bar icon with fixed width
        iconItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = iconItem?.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer")
            button.target = self
            button.action = #selector(handleStatusItemClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Create the menu but don't assign it yet
        statusMenu = NSMenu()
        statusMenu?.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        // A text item will also be created dynamically when a goal is active
        
        // Popover window that appears when the menu bar icon is clicked
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 450) 
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView(timerService: timerService))

        // Subscribe to timer service changes to update the menu bar text
        setupTimerObservers(timerService)
    }

    @objc private func handleStatusItemClick(_ sender: NSStatusBarButton) {
        if let event = NSApp.currentEvent {
            switch event.type {
            case .rightMouseUp:
                iconItem?.menu = statusMenu // Assign menu only for right click
                statusMenu?.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: sender)
                iconItem?.menu = nil // Remove menu after it's shown
            case .leftMouseUp:
                togglePopover(sender)
            default:
                break
            }
        }
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
        if let goalID = goalID, let goal = timerService?.goal(with: goalID) {
            // Create text item if it doesn't exist
            if textItem == nil {
                textItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
                if let textButton = textItem?.button {
                    textButton.action = #selector(togglePopover(_:))
                }
            }
            
            guard let textButton = textItem?.button else { return }
            
            // Format elapsed time
            let hours = Int(elapsedTime) / 3600
            let minutes = Int(elapsedTime) / 60 % 60
            let timeString = hours > 0 ? String(format: "%d:%02d", hours, minutes) : String(format: "%d min", minutes)
            
            // Truncate goal name if needed (max 15 chars)
            let truncatedName = goal.name.count > 15 ? 
                goal.name.prefix(12) + "..." : 
                goal.name
            
            // Set the title
            textButton.title = "\(truncatedName) (\(timeString))"
        } else {
            // Completely remove the text item when no goal is active
            if let textItem = textItem {
                NSStatusBar.system.removeStatusItem(textItem)
                self.textItem = nil
            }
        }
    }

    // This @objc function is called when the status item button (menu bar icon) is clicked.
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let popover = popover, let button = iconItem?.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            // Disable animations for instant appearance
            popover.animates = false
            
            // Pre-configure the app state
            NSApp.activate(ignoringOtherApps: true)
            
            // Configure the popover before showing
            if let popoverWindow = popover.contentViewController?.view.window {
                popoverWindow.level = .floating
            }
            
            // Show the popover
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            
            // Make key window after showing
            if let popoverWindow = popover.contentViewController?.view.window {
                popoverWindow.makeKey()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Save any active timer state before the app quits.
        timerService?.saveCurrentStateAndStopTimer()
    }
} 