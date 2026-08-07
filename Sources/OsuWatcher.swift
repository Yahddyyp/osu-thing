import AppKit
import ApplicationServices
import Foundation

final class OsuWatcher: @unchecked Sendable {

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
            print("Automatic enable is OFF")
            return
        }

        guard let app = NSWorkspace.shared.frontmostApplication else {
            print("No frontmost app")
            settings.driverState = .disable
            return
        }

        guard app.bundleIdentifier == "sh.ppy.osu.lazer" else {
            settings.driverState = .disable
            return
        }

        settings.driverState =
            isPlayingBeatmap()
            ? .enable
            : .disable
    }

    private func isPlayingBeatmap() -> Bool {

        guard let app = NSWorkspace.shared.frontmostApplication else {
            return false
        }

        let application = AXUIElementCreateApplication(app.processIdentifier)

        var value: CFTypeRef?

        let focusedResult = AXUIElementCopyAttributeValue(
            application,
            kAXFocusedWindowAttribute as CFString,
            &value
        )

        guard focusedResult == .success else {
            return false
        }

        let window = value as! AXUIElement

        var titleValue: CFTypeRef?

        let titleResult = AXUIElementCopyAttributeValue(
            window,
            kAXTitleAttribute as CFString,
            &titleValue
        )

        guard titleResult == .success else {
            return false
        }

        guard let title = titleValue as? String else {
            print("Window title wasn't a String")
            return false
        }

        let normalized =
            title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return normalized != "osu!"
    }
}
