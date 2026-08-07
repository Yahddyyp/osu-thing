import AppKit
import ApplicationServices
import Foundation

final class OsuWatcher {

    private let settings: Settings

    private var timer: Timer?

    init(settings: Settings) {
        self.settings = settings
    }

    func start() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true
        ) { [weak self] _ in
            self?.update()
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func update() {

        guard settings.automaticEnable else {
            return
        }

        guard let app = NSWorkspace.shared.frontmostApplication else {
            settings.driverState = .disable
            return
        }

        guard app.bundleIdentifier == "sh.ppy.osulazer" else {
            settings.driverState = .disable
            return
        }

        if isPlayingBeatmap() {
            settings.driverState = .enable
        } else {
            settings.driverState = .disable
        }
    }

    private func isPlayingBeatmap() -> Bool {

        guard
            let app = NSWorkspace.shared.frontmostApplication,
            let pid = app.processIdentifier as pid_t?
        else {
            return false
        }

        let application = AXUIElementCreateApplication(pid)

        var value: CFTypeRef?

        let result = AXUIElementCopyAttributeValue(
            application,
            kAXWindowsAttribute as CFString,
            &value
        )

        guard
            result == .success,
            let windows = value as? [AXUIElement],
            let window = windows.first
        else {
            return false
        }

        var titleValue: CFTypeRef?

        guard
            AXUIElementCopyAttributeValue(
                window,
                kAXTitleAttribute as CFString,
                &titleValue
            ) == .success,
            let title = titleValue as? String
        else {
            return false
        }

        print(title)

        return title != "osu!"
    }
}
