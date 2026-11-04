import SwiftUI

struct SettingsView: View {
    let settings: Settings
    let touchState: TouchState

    @State private var editingArea: ActiveArea
    @State private var selectedTab: SettingsTab = .activeArea

    private enum SettingsTab: String, CaseIterable {
        case activeArea = "Active Area"
        case settings = "Settings"
    }

    init(settings: Settings, touchState: TouchState) {
        self.settings = settings
        self.touchState = touchState
        _editingArea = State(initialValue: settings.activeArea)
    }

    var body: some View {
        VStack(spacing: 18) {
            header

            Picker("", selection: $selectedTab) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .frame(maxWidth: 320)

            Group {
                switch selectedTab {
                case .activeArea:
                    activeAreaTab

                case .settings:
                    settingsTab
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if selectedTab == .activeArea {
                activeAreaActions
            }
        }
        .padding(24)
        .frame(width: 900, height: 580)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("osu-thing")
                    .font(.title2.weight(.bold))

                Text("Trackpad driver")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            statusIndicator
        }
    }

    private var statusIndicator: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(driverIsEnabled ? .green : .secondary)
                .frame(width: 7, height: 7)

            Text(driverIsEnabled ? "Driver Enabled" : "Driver Disabled")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(.quaternary.opacity(0.25), in: Capsule())
    }

    private var driverIsEnabled: Bool {
        settings.driverState == .enable
    }

    private var activeAreaTab: some View {
        HStack(alignment: .center, spacing: 20) {
            areaControlsCard
                .frame(width: 300)

            trackpadPreviewCard
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var areaControlsCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Active Area")
                .font(.title3.weight(.semibold))

            VStack(spacing: 15) {
                areaSlider("Left", value: leftBinding)
                areaSlider("Right", value: rightBinding)

                Divider()

                areaSlider("Min Y", value: minYBinding)
                areaSlider("Max Y", value: maxYBinding)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(cardBackground)
    }

    private var trackpadPreviewCard: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Trackpad Preview")
                    .font(.headline)

                Spacer()
            }

            TrackpadView(
                settings: settings,
                touchState: touchState,
                area: $editingArea
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(cardBackground)
    }

    private func areaSlider(
        _ title: String,
        value: Binding<Float>
    ) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Text(String(format: "%.3f", value.wrappedValue))
                    .font(.system(.subheadline, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }

            Slider(
                value: Binding(
                    get: { Double(value.wrappedValue) },
                    set: { value.wrappedValue = Float($0) }
                ),
                in: 0...1
            )
            .controlSize(.regular)
        }
    }

    private var leftBinding: Binding<Float> {
        Binding(
            get: { editingArea.left },
            set: { editingArea.left = min(max($0, 0), 1) }
        )
    }

    private var rightBinding: Binding<Float> {
        Binding(
            get: { editingArea.right },
            set: { editingArea.right = min(max($0, 0), 1) }
        )
    }

    private var minYBinding: Binding<Float> {
        Binding(
            get: { editingArea.minY },
            set: { editingArea.minY = min(max($0, 0), 1) }
        )
    }

    private var maxYBinding: Binding<Float> {
        Binding(
            get: { editingArea.maxY },
            set: { editingArea.maxY = min(max($0, 0), 1) }
        )
    }

    private var settingsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 0) {
                settingsRow(
                    title: "Automatically enable while playing a beatmap",
                    description: "Enable the driver when a beatmap starts.",
                    isOn: Binding(
                        get: { settings.automaticEnable },
                        set: { settings.automaticEnable = $0 }
                    )
                )

                Divider()
                    .padding(.vertical, 12)

                settingsRow(
                    title: "Lock Aspect Ratio",
                    description:
                        "Keep the active area's proportions consistent to the display while adjusting it.",
                    isOn: Binding(
                        get: { settings.lockAspectRatio },
                        set: { settings.lockAspectRatio = $0 }
                    )
                )
            }
            .padding(18)
            .background(cardBackground)

            Spacer(minLength: 0)
        }
        .padding(.top, 4)
    }

    private func settingsRow(
        title: String,
        description: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.medium))

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .fixedSize()
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.quaternary.opacity(0.16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.quaternary.opacity(0.7), lineWidth: 1)
            }
    }

    private var activeAreaActions: some View {
        HStack(spacing: 10) {
            Button("Reset Area") {
                editingArea = .default
            }
            .disabled(editingArea == .default)

            Button("Cancel") {
                editingArea = settings.activeArea
            }
            .disabled(editingArea == settings.activeArea)

            Spacer()

            if !settings.automaticEnable {
                Button(
                    settings.driverState == .enable
                        ? "Disable Driver"
                        : "Enable Driver"
                ) {
                    settings.driverState =
                        settings.driverState == .enable ? .disable : .enable
                }
            }

            Button("Apply") {
                settings.activeArea = editingArea
                settings.save()
            }
            .buttonStyle(.borderedProminent)
            .disabled(editingArea == settings.activeArea)
        }
        .padding(.top, 4)
    }
}
