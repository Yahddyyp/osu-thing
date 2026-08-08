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

interceptor.start()

let watcher = OsuWatcher(
    settings: settings
)

watcher.start()

let hotkeys = HotKeyManager(
    settings: settings
)

hotkeys.register()

let app = NSApplication.shared

app.setActivationPolicy(.regular)

let delegate = AppDelegate(
    settings: settings,
    touchState: touchState
)

app.delegate = delegate

app.run()
