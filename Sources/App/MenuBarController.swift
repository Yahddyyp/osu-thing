import AppKit

@MainActor
final class MenuBarController: NSObject, NSMenuDelegate {
    private let settings: Settings
    private let openSettings: () -> Void
    private let statusItem: NSStatusItem
    private let menu = NSMenu()
    private let toggleDriver: () -> Void
    private let isDriverEnabled: () -> Bool

    init(
        settings: Settings,
        openSettings: @escaping () -> Void,
        toggleDriver: @escaping () -> Void,
        isDriverEnabled: @escaping () -> Bool
    ) {
        self.settings = settings
        self.openSettings = openSettings
        self.toggleDriver = toggleDriver
        self.isDriverEnabled = isDriverEnabled

        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        super.init()

        setupStatusItem()
        setupMenu()
        updateMenu()
    }

    private func setupStatusItem() {
        guard let button = statusItem.button else {
            return
        }

        button.image = NSImage(
            // TODO: Change this icon
            systemSymbolName: "computermouse",
            accessibilityDescription: "osu-thing"
        )

        button.toolTip = "osu-thing"
        statusItem.menu = menu
    }

    private func setupMenu() {
        menu.delegate = self
    }

    func menuWillOpen(_ menu: NSMenu) {
        updateMenu()
    }

    private func updateMenu() {
        menu.removeAllItems()

        let driverItem = NSMenuItem(
            title: isDriverEnabled() ? "Disable Driver" : "Enable Driver",
            action: #selector(toggleDriverAction),
            keyEquivalent: ""
        )
        driverItem.target = self
        menu.addItem(driverItem)

        let settingsItem = NSMenuItem(
            title: "Settings…",
            action: #selector(openSettingsWindow),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit osu-thing",
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
}
