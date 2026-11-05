import AppKit

@MainActor
final class MenuBarController: NSObject, NSMenuDelegate {
    private let settings: Settings
    private let openSettings: () -> Void
    private let statusItem: NSStatusItem
    private let menu = NSMenu()
    private let toggleDriver: () -> Void
    private let isDriverEnabled: () -> Bool
    private let accessibilityManager: AccessibilityManager

    private var menuRefreshTimer: Timer?
    private var lastAutomaticEnable: Bool

    init(
        settings: Settings,
        openSettings: @escaping () -> Void,
        toggleDriver: @escaping () -> Void,
        isDriverEnabled: @escaping () -> Bool,
        accessibilityManager: AccessibilityManager
    ) {
        self.settings = settings
        self.openSettings = openSettings
        self.toggleDriver = toggleDriver
        self.isDriverEnabled = isDriverEnabled
        self.lastAutomaticEnable = settings.automaticEnable
        self.accessibilityManager = accessibilityManager

        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        super.init()

        setupStatusItem()
        setupMenu()
        updateMenu()
        startMenuRefreshTimer()
    }

    private func setupStatusItem() {
        guard let button = statusItem.button else {
            return
        }

        button.image = NSImage(
            systemSymbolName: "cursorarrow.click",
            accessibilityDescription: "osu-thing"
        )

        button.toolTip = "osu-thing"
        statusItem.menu = menu
    }

    private func setupMenu() {
        menu.delegate = self
    }

    private func startMenuRefreshTimer() {
        menuRefreshTimer = Timer.scheduledTimer(
            withTimeInterval: 0.25,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshMenuIfNeeded()
            }
        }
    }

    private func refreshMenuIfNeeded() {
        guard settings.automaticEnable != lastAutomaticEnable else {
            return
        }

        lastAutomaticEnable = settings.automaticEnable
        updateMenu()
    }

    func menuWillOpen(_ menu: NSMenu) {
        updateMenu()
    }

    private func updateMenu() {
        menu.removeAllItems()

        if !settings.automaticEnable {
            if accessibilityManager.isGranted {
                let driverItem = NSMenuItem(
                    title: isDriverEnabled() ? "Disable Driver" : "Enable Driver",
                    action: #selector(toggleDriverAction),
                    keyEquivalent: ""
                )
                driverItem.target = self
                menu.addItem(driverItem)
            } else {
                let permissionItem = NSMenuItem(
                    title: "Grant Accessibility Access…",
                    action: #selector(openAccessibilitySettings),
                    keyEquivalent: ""
                )
                permissionItem.target = self
                menu.addItem(permissionItem)
            }
        }

        let settingsItem = NSMenuItem(
            title: "Settings…",
            action: #selector(openSettingsWindow),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: ""
        )
        quitItem.target = self
        menu.addItem(quitItem)
    }

    @objc
    private func toggleDriverAction() {
        toggleDriver()
        updateMenu()
    }

    @objc
    private func openSettingsWindow() {
        openSettings()
    }

    @objc
    private func quitApp() {
        NSApp.terminate(nil)
    }

    @objc private func openAccessibilitySettings() {
        accessibilityManager.openSystemSettings()
    }
}
