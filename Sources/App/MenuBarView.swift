import SwiftUI

struct MenuBarView: View {
    let settings: Settings
    let accessibilityManager: AccessibilityManager
    let openSettings: () -> Void
    let quitApp: () -> Void

    var body: some View {
        if !settings.automaticEnable {
            if accessibilityManager.isGranted {
                Button(
                    settings.driverState == .enable
                        ? "Disable Driver"
                        : "Enable Driver"
                ) {
                    settings.driverState =
                        settings.driverState == .enable
                        ? .disable
                        : .enable
                }
            } else {
                Button("Grant Accessibility Access…") {
                    accessibilityManager.openSystemSettings()
                }
            }
        }

        Button("Settings…", action: openSettings)

        Divider()

        Button("Quit osu! Trackpad Driver", action: quitApp)
    }
}
