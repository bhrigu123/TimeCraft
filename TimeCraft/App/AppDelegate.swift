import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item.
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer")
            button.action = #selector(togglePopover(_:))
        }

        // Create the popover.
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 250, height: 220)
        popover?.behavior = .transient
        // We will create ContentView later
        popover?.contentViewController = NSHostingController(rootView: ContentView())
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(sender)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover?.contentViewController?.view.window?.makeKeyAndOrderFront(nil)
            }
        }
    }
} 