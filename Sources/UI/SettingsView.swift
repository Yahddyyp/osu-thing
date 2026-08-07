import SwiftUI

struct SettingsView: View {
    let settings: Settings
    let touchState: TouchState

    @State private var editingArea: ActiveArea

    init(settings: Settings, touchState: TouchState) {
        self.settings = settings
        self.touchState = touchState
        _editingArea = State(initialValue: settings.activeArea)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("osu! Trackpad Driver")
                .font(.largeTitle)

            Text("Active Area")
                .font(.headline)

            TrackpadView(
                settings: settings,
                touchState: touchState,
                area: $editingArea
            )

            Toggle(
                "Automatically enable while playing osu",
                isOn: Binding(
                    get: { settings.automaticEnable },
                    set: { settings.automaticEnable = $0 }
                )
            )

            HStack {

                Button("Reset") {
                    editingArea = .default
                }
                .disabled(editingArea == .default)

                Button("Cancel") {
                    editingArea = settings.activeArea

                    if !settings.automaticEnable {
                        settings.driverState = .enable
                    }
                }

                Spacer()

                Button("Apply") {
                    settings.activeArea = editingArea
                    settings.save()

                    if !settings.automaticEnable {
                        settings.driverState = .enable
                    }
                }

                if !settings.automaticEnable {

                    Button(settings.driverState == .enable ? "Disable Driver" : "Enable Driver") {

                        if settings.driverState == .enable {
                            settings.driverState = .disable
                        } else {
                            settings.driverState = .enable
                        }

                    }

                }

            }
        }

        VStack(alignment: .leading, spacing: 4) {
            Text("Current Area")
                .font(.headline)

            Text(String(format: "Left:   %.3f", editingArea.left))
            Text(String(format: "Right:  %.3f", editingArea.right))
            Text(String(format: "Min Y:  %.3f", editingArea.minY))
            Text(String(format: "Max Y:  %.3f", editingArea.maxY))
        }
        .font(.system(.body, design: .monospaced))

        .padding().onAppear {
            if !settings.automaticEnable {
                settings.driverState = .editing
            }
        }
    }
}
