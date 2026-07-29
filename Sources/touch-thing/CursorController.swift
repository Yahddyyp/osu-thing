import CoreGraphics

final class CursorController {
    func move(to point: CGPoint) {
        CGWarpMouseCursorPosition(point)
    }
}
