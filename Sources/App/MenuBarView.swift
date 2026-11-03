import SwiftUI

struct MenuBarView: View {
    let settings: Settings
    let openSettings: () -> Void
    let quitApp: () -> Void

    var body: some View {
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

        Button("Settings…", action: openSettings)

        Divider()

        Button("Quit osu! Trackpad Driver", action: quitApp)
    }
}
