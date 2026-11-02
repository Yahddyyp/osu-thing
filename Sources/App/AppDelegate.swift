import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings: Settings
    private let touchState: TouchState
    private let accessibilityManager: AccessibilityManager
    private let onAccessibilityGranted: () -> Void

    private var window: NSWindow?
    private var didStartComponents = false

    init(
        settings: Settings,
        touchState: TouchState,
        accessibilityManager: AccessibilityManager,
        onAccessibilityGranted: @escaping () -> Void
    ) {
        self.settings = settings
        self.touchState = touchState
        self.accessibilityManager = accessibilityManager
        self.onAccessibilityGranted = onAccessibilityGranted

        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMainMenu()
        showWindow()

        accessibilityManager.checkPermission()
        updatePermissionState()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc
    private func applicationDidBecomeActive() {
        accessibilityManager.checkPermission()
        updatePermissionState()
    }

    private func updatePermissionState() {
        guard accessibilityManager.isGranted else {
            window?.contentView = NSHostingView(
                rootView: AccessibilityPermissionView(
                    manager: accessibilityManager
                )
            )
            return
        }

        window?.contentView = NSHostingView(
            rootView: SettingsView(
                settings: settings,
                touchState: touchState
            )
        )

        guard !didStartComponents else {
            return
        }

        didStartComponents = true
        onAccessibilityGranted()
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
            title: "Quit osu-thing",
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

        window.title = "osu-thing"
        window.center()
        window.isReleasedWhenClosed = false

        self.window = window

        updatePermissionState()

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
