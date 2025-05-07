//
//  TimeCraftApp.swift
//  TimeCraft
//
//  Created by Bhrigu Srivastava on 5/6/25.
//

import SwiftUI

@main
struct TimeCraftApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty scene for menu bar app
        Settings { }
    }
}
