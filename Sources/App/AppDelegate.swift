import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private let settings: Settings
    private let touchState: TouchState
    private let accessibilityManager: AccessibilityManager
    private let onAccessibilityGranted: () -> Void

    private var menuBarController: MenuBarController?
    private var hasInstalledContent = false
    private var window: NSWindow?
    private var didStartComponents = false
    private var didInstallGrantedContent = false

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

        menuBarController = MenuBarController(
            settings: settings,
            openSettings: { [weak self] in
                self?.showWindow()
            },
            toggleDriver: { [weak self] in
                guard let self else { return }

                self.settings.driverState =
                    self.settings.driverState == .enable ? .disable : .enable
            },
            isDriverEnabled: { [weak self] in
                self?.settings.driverState == .enable
            }
        )

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
        let isGranted = accessibilityManager.isGranted

        // Don't replace the content view unless permission state changed.
        guard !hasInstalledContent || isGranted != didInstallGrantedContent else {
            return
        }

        hasInstalledContent = true
        didInstallGrantedContent = isGranted

        if !isGranted {
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

    func showWindow() {
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
        window.delegate = self

        updatePermissionState()

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
