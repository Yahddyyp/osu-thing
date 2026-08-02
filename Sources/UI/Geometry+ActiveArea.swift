import CoreGraphics
import Foundation

struct UIRect {
    var left: CGFloat
    var top: CGFloat
    var right: CGFloat
    var bottom: CGFloat

    var width: CGFloat { right - left }
    var height: CGFloat { bottom - top }

    var center: CGPoint {
        CGPoint(x: (left + right) / 2, y: (top + bottom) / 2)
    }
}

func makeUIRect(from area: ActiveArea, size: CGSize) -> UIRect {
    UIRect(
        left: CGFloat(area.left) * size.width,
        top: (1 - CGFloat(area.maxY)) * size.height,
        right: CGFloat(area.right) * size.width,
        bottom: (1 - CGFloat(area.minY)) * size.height
    )
}

func makeActiveArea(from rect: UIRect, size: CGSize) -> ActiveArea {
    ActiveArea(
        left: Float(rect.left / size.width),
        right: Float(rect.right / size.width),
        minY: Float(1 - rect.bottom / size.height),
        maxY: Float(1 - rect.top / size.height)
    )
}

extension UIRect {
    func translated(by translation: CGSize, in size: CGSize) -> UIRect {
        var newLeft = left + translation.width
        var newTop = top + translation.height

        newLeft = min(max(newLeft, 0), max(0, size.width - width))
        newTop = min(max(newTop, 0), max(0, size.height - height))

        return UIRect(
            left: newLeft,
            top: newTop,
            right: newLeft + width,
            bottom: newTop + height
        )
    }
}

// Clamp value to the inclusive range
func clamp(_ value: CGFloat, min lower: CGFloat, max upper: CGFloat) -> CGFloat {
    min(max(value, lower), upper)
}
