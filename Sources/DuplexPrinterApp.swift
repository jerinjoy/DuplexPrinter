//
//  DuplexPrinterApp.swift
//  DuplexPrinter
//
//  Created by Jerin Joy & Noel Joy on 2026.
//  Copyright © 2026 Jerin Joy & Noel Joy. All rights reserved.
//

import SwiftUI

@main
struct DuplexPrinterApp: App {
    @AppStorage("dryRunEnabled") private var dryRunEnabled = false

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .commands {
            CommandMenu("Debug") {
                Toggle("Enable Dry Run", isOn: $dryRunEnabled)
            }
        }
    }
}
