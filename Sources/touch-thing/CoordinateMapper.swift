import CoreGraphics
import Foundation

final class CoordinateMapper {
    func map(x: Float, y: Float) -> CGPoint {
        let screen = CGDisplayBounds(CGMainDisplayID())

        let screenX = CGFloat(x) * screen.width
        let screenY = (1 - CGFloat(y)) * screen.height

        return CGPoint(
            x: screenX,
            y: screenY
        )
    }

}
