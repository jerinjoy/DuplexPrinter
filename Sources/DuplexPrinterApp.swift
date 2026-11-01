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
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
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

final class OpenedDocument: ObservableObject {
    static let shared = OpenedDocument()
    @Published var url: URL?
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    // Receives PDFs from Finder "Open With" and from the print dialog's PDF menu.
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first(where: { $0.pathExtension.lowercased() == "pdf" }) else { return }
        OpenedDocument.shared.url = url
        NSApp.activate(ignoringOtherApps: true)
    }

    // Otherwise a PDF opened after the window is closed would have nowhere to go.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

/// Items in ~/Library/PDF Services appear in the print dialog's PDF menu; choosing one
/// saves the job as a PDF and opens it with that app.
enum PDFServices {
    private static var linkURL: URL {
        // The sandbox redirects NSHomeDirectory() to the container; the entitlement exception is for the real home.
        let home = String(cString: getpwuid(getuid()).pointee.pw_dir)
        return URL(fileURLWithPath: home)
            .appendingPathComponent("Library/PDF Services/Duplex Printer.app")
    }

    static var isInstalled: Bool {
        (try? FileManager.default.destinationOfSymbolicLink(atPath: linkURL.path)) == Bundle.main.bundlePath
    }

    static func setInstalled(_ install: Bool) {
        let fm = FileManager.default
        do {
            if (try? fm.destinationOfSymbolicLink(atPath: linkURL.path)) != nil {
                try fm.removeItem(at: linkURL)
            }
            if install {
                try fm.createDirectory(at: linkURL.deletingLastPathComponent(), withIntermediateDirectories: true)
                try fm.createSymbolicLink(atPath: linkURL.path, withDestinationPath: Bundle.main.bundlePath)
            }
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }
}
