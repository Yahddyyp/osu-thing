import CoreGraphics
import Observation

final class MouseInterceptor {

    private let settings: Settings
    private var eventTap: CFMachPort?

    init(settings: Settings) {
        self.settings = settings
    }

    func start() {

        let mask =
            (1 << CGEventType.mouseMoved.rawValue)
            | (1 << CGEventType.leftMouseDragged.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: { proxy, type, event, userInfo in

                let interceptor = Unmanaged<MouseInterceptor>
                    .fromOpaque(userInfo!)
                    .takeUnretainedValue()

                guard interceptor.settings.driverState == .enable else {
                    return Unmanaged.passRetained(event)
                }

                if type == .mouseMoved {

                    let tag = event.getIntegerValueField(.eventSourceUserData)

                    if tag == CursorController.syntheticEventTag {
                        return Unmanaged.passRetained(event)
                    }

                    return nil
                }

                return Unmanaged.passRetained(event)

            },
            userInfo: UnsafeMutableRawPointer(
                Unmanaged.passUnretained(self).toOpaque()
            )
        )

        guard let eventTap else {
            // print("Failed to create event tap")
            return
        }

        let source = CFMachPortCreateRunLoopSource(
            kCFAllocatorDefault,
            eventTap,
            0
        )

        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            source,
            .commonModes
        )

        CGEvent.tapEnable(
            tap: eventTap,
            enable: true
        )
    }
}
