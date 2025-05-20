import SwiftUI

// The AppDelegate is responsible for managing application-level events and behaviors,
// particularly those not fully handled by the standard SwiftUI app lifecycle.
// For this menu bar app, it manages the NSStatusItem (the menu bar icon) and the NSPopover (the window that appears).
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var timerService: GoalTimerService? // Hold the timer service instance

    // Called when the application has finished launching and is ready to run.
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the timer service instance
        let timerService = GoalTimerService()
        self.timerService = timerService

        // Create the status item (the icon in the menu bar).
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer")
            button.action = #selector(togglePopover(_:))
        }

        // Create and configure the popover.
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 450) 
        popover?.behavior = .transient
        // Pass the timerService to ContentView
        popover?.contentViewController = NSHostingController(rootView: ContentView(timerService: timerService))
    }

    // This @objc function is called when the status item button (menu bar icon) is clicked.
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let popover = popover else { return }

        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(sender) // If the popover is already shown, close it.
            } else {
                // If the popover is not shown, show it relative to the menu bar button.
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                // Make the popover's window the key window and bring it to the front to ensure it receives events.
                popover.contentViewController?.view.window?.makeKeyAndOrderFront(nil)
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Save any active timer state before the app quits.
        timerService?.saveCurrentStateBeforeQuit()
    }
} 