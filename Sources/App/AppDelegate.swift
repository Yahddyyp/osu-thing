import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings: Settings
    private let touchState: TouchState

    private var window: NSWindow?

    init(settings: Settings, touchState: TouchState) {
        self.settings = settings
        self.touchState = touchState
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMainMenu()
        showWindow()
    }

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows flag: Bool
    ) -> Bool {
        if !flag {
            showWindow()
        }

        return true
    }

    private func setupMainMenu() {
        let mainMenu = NSMenu()

        // App menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()

        let quitItem = NSMenuItem(
            title: "Quit osu! Trackpad Driver",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )

        appMenu.addItem(quitItem)
        appMenuItem.submenu = appMenu

        // Window menu
        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)

        let windowMenu = NSMenu(title: "Window")

        let closeItem = NSMenuItem(
            title: "Close Window",
            action: #selector(NSWindow.performClose(_:)),
            keyEquivalent: "w"
        )

        windowMenu.addItem(closeItem)
        windowMenuItem.submenu = windowMenu

        NSApp.mainMenu = mainMenu
    }

    private func showWindow() {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(
                x: 100,
                y: 100,
                width: 800,
                height: 600
            ),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
            ],
            backing: .buffered,
            defer: false
        )

        window.title = "osu! Trackpad Driver"
        window.center()

        window.contentView = NSHostingView(
            rootView: SettingsView(
                settings: settings,
                touchState: touchState
            )
        )

        window.isReleasedWhenClosed = false

        self.window = window

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
