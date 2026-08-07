import CoreGraphics
import Foundation

final class CoordinateMapper {
    private let settings: Settings

    init(settings: Settings) {
        self.settings = settings
    }

    private func effectiveArea() -> ActiveArea {
        if !settings.lockAspectRatio {
            return settings.activeArea
        }

        let area = settings.activeArea

        let width = area.right - area.left
        let height = area.maxY - area.minY

        let screen = CGDisplayBounds(CGMainDisplayID())
        let screenAspect = Float(screen.width / screen.height)
        let areaAspect = width / height

        // Already correct
        if abs(areaAspect - screenAspect) < 0.0001 {
            return area
        }

        var result = area

        if areaAspect > screenAspect {
            // Too wide -> crop width
            let newWidth = height * screenAspect
            let center = (area.left + area.right) / 2

            result.left = center - newWidth / 2
            result.right = center + newWidth / 2
        } else {
            // Too tall -> crop height
            let newHeight = width / screenAspect
            let center = (area.minY + area.maxY) / 2

            result.minY = center - newHeight / 2
            result.maxY = center + newHeight / 2
        }

        // print(result)
        return result
    }

    func map(x: Float, y: Float) -> CGPoint {

        let area = effectiveArea()

        let normalizedX = (x - area.left) / (area.right - area.left)
        let normalizedY = (y - area.minY) / (area.maxY - area.minY)

        let clampedX = min(max(normalizedX, 0), 1)
        let clampedY = min(max(normalizedY, 0), 1)

        let screen = CGDisplayBounds(CGMainDisplayID())

        return CGPoint(
            x: Double(clampedX) * screen.width,
            y: (1 - Double(clampedY)) * screen.height
        )
    }
}
