import CoreGraphics

final class CursorController {
    static let syntheticEventTag: Int64 = 0x4F53_5554  // "OSUT" tag, arbitrary but unique

    private var lastPoint: CGPoint?

    func move(to point: CGPoint) {
        defer { lastPoint = point }

        let dx = point.x - (lastPoint?.x ?? point.x)
        let dy = point.y - (lastPoint?.y ?? point.y)

        guard let event = CGEvent(
            mouseEventSource: nil,
            mouseType: .mouseMoved,
            mouseCursorPosition: point,
            mouseButton: .left
        ) else { return }

        event.setIntegerValueField(.mouseEventDeltaX, value: Int64(dx))
        event.setIntegerValueField(.mouseEventDeltaY, value: Int64(dy))
        event.setIntegerValueField(.eventSourceUserData, value: Self.syntheticEventTag)

        event.post(tap: .cgSessionEventTap)
    }
}
