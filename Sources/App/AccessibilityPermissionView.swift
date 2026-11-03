import SwiftUI

struct AccessibilityPermissionView: View {
    @ObservedObject var manager: AccessibilityManager

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.accentColor)

            Text("Accessibility Permission Required")
                .font(.title2.bold())

            Text(
                """
                osu-thing needs Accessibility permission
                """
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
            .frame(maxWidth: 420)

            Button("Grant Access") {
                manager.requestPermission()
            }
            .buttonStyle(.borderedProminent)

            Button("Open System Settings") {
                manager.openSystemSettings()
            }

            Text("System Settings → Privacy & Security → Accessibility")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}
