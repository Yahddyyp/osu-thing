import AppKit
import ApplicationServices
import SwiftUI

@MainActor
final class AccessibilityManager: ObservableObject {
    @Published private(set) var isGranted = false

    func checkPermission() {
        isGranted = AXIsProcessTrusted()
    }

    func requestPermission() {
        let options =
            [
                "AXTrustedCheckOptionPrompt": true
            ] as CFDictionary

        _ = AXIsProcessTrustedWithOptions(options)

        checkPermission()
    }

    func openSystemSettings() {
        guard
            let url = URL(
                string:
                    "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
            )
        else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}
