import Foundation
import SwiftUI

let settings = Settings()
let touchState = TouchState()

let manager = TouchManager(
    settings: settings,
    touchState: touchState
)

let interceptor = MouseInterceptor()
interceptor.start()

let app = NSApplication.shared

let window = NSWindow(
    contentRect: NSRect(x: 100, y: 100, width: 500, height: 400),
    styleMask: [.titled, .closable, .miniaturizable, .resizable],
    backing: .buffered,
    defer: false
)

window.title = "osu! Trackpad Driver"
window.center()

window.contentView = NSHostingView(
    rootView: SettingsView(
        settings: settings,
        touchState: touchState
    )
)

let hotkeys = HotKeyManager(settings: settings)
hotkeys.register()

window.makeKeyAndOrderFront(nil)

app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)

app.run()
