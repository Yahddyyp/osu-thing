import CoreGraphics

final class MouseInterceptor {
    private var eventTap: CFMachPort?

    func start() {
        let mask =
            (1 << CGEventType.mouseMoved.rawValue) | (1 << CGEventType.leftMouseDragged.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: { _, type, event, _ in
                if type == .mouseMoved {
                    let tag = event.getIntegerValueField(.eventSourceUserData)
                    if tag == CursorController.syntheticEventTag {
                        return Unmanaged.passRetained(event)
                    }
                    return nil
                }
                return Unmanaged.passRetained(event)
            },
            userInfo: nil)

        guard let eventTap else {
            print("Failed to create event tap")
            return
        }

        print("Event tap created!")

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)

        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)

        CGEvent.tapEnable(
            tap: eventTap,
            enable: true
        )
    }

    func stop() {}
}
