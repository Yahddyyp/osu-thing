import Foundation
import SwiftUI

let settings = Settings()
let touchState = TouchState()

let manager = TouchManager(
    settings: settings,
    touchState: touchState
)

let watcher = OsuWatcher(settings: settings)
watcher.start()

let interceptor = MouseInterceptor(settings: settings)
interceptor.start()

let app = NSApplication.shared

let contentView = SettingsView(
    settings: settings,
    touchState: touchState
)

let hostingView = NSHostingView(rootView: contentView)

let window = NSWindow(
    contentRect: .zero,
    styleMask: [.titled, .closable, .miniaturizable, .resizable],
    backing: .buffered,
    defer: false
)

window.title = "osu! Trackpad Driver"
window.contentView = hostingView

let fittingSize = hostingView.fittingSize
window.setContentSize(
    NSSize(
        width: max(fittingSize.width, 800),
        height: fittingSize.height
    )
)
window.center()

let hotkeys = HotKeyManager(settings: settings)
hotkeys.register()

window.makeKeyAndOrderFront(nil)

app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)

app.run()
