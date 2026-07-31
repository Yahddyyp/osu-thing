import CoreGraphics
import Foundation

final class CoordinateMapper {
    private let settings: Settings

    init(settings: Settings) {
        self.settings = settings
    }

    func map(x: Float, y: Float) -> CGPoint {
        let area = settings.activeArea

        let normalizedX = (x - area.left) / (area.right - area.left)
        let normalizedY = (y - area.top) / (area.bottom - area.top)

        let clampedX = min(max(normalizedX, 0), 1)
        let clampedY = min(max(normalizedY, 0), 1)

        guard let screen = CGDisplayBounds(CGMainDisplayID()) as CGRect? else {
            return .zero
        }

        let screenX = Double(clampedX) * screen.width
        let screenY = (1 - Double(clampedY)) * screen.height

        return CGPoint(
            x: screenX,
            y: screenY
        )
    }
}
