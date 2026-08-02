import Carbon
import Foundation

final class HotKeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private let settings: Settings

    init(settings: Settings) {
        self.settings = settings
    }
    func register() {
        var hotKeyID = EventHotKeyID(
            signature: OSType(0x4F53_5554),
            id: 1
        )

        RegisterEventHotKey(
            UInt32(kVK_F8),
            0,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in

                guard
                    let event,
                    let userData
                else {
                    return noErr
                }

                let manager = Unmanaged<HotKeyManager>
                    .fromOpaque(userData)
                    .takeUnretainedValue()

                manager.toggleDriver()

                return noErr
            },
            1,
            &eventSpec,
            UnsafeMutableRawPointer(
                Unmanaged.passUnretained(self).toOpaque()
            ),
            nil
        )
    }

    private func toggleDriver() {
        switch settings.driverState {
        case .enable:
            settings.driverState = .disable

        case .disable, .editing:
            settings.driverState = .enable
        }

        print("Driver:", settings.driverState)
    }

}
