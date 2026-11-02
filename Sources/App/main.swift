import AppKit
import Foundation

let settings = Settings()
let touchState = TouchState()

let manager = TouchManager(
    settings: settings,
    touchState: touchState
)

let interceptor = MouseInterceptor(
    settings: settings
)

let watcher = OsuWatcher(
    settings: settings
)

let hotkeys = HotKeyManager(
    settings: settings
)

let accessibilityManager = AccessibilityManager()

let app = NSApplication.shared
app.setActivationPolicy(.regular)

let delegate = AppDelegate(
    settings: settings,
    touchState: touchState,
    accessibilityManager: accessibilityManager
) {
    interceptor.start()
    watcher.start()
    hotkeys.register()
}

app.delegate = delegate
app.run()
