import SwiftUI

// Which visual corner of the active-area rectangle is being dragged.
enum ResizeCorner {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

struct ResizeHandle: View {
    @Binding var area: ActiveArea
    let corner: ResizeCorner
    let rect: UIRect
    let size: CGSize
    let onDragBegan: () -> Void
    let onDragEnded: () -> Void

    @State private var dragStartRect: UIRect?

    private var position: CGPoint {
        switch corner {
        case .topLeft: CGPoint(x: rect.left, y: rect.top)
        case .topRight: CGPoint(x: rect.right, y: rect.top)
        case .bottomLeft: CGPoint(x: rect.left, y: rect.bottom)
        case .bottomRight: CGPoint(x: rect.right, y: rect.bottom)
        }
    }

    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 18, height: 18)
            .contentShape(Rectangle())
            .position(position)
            .gesture(drag)
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                if dragStartRect == nil {
                    dragStartRect = rect
                    onDragBegan()
                }
                guard let start = dragStartRect else { return }

                let newRect = start.resized(
                    from: corner,
                    by: value.translation,
                    in: size
                )

                area = makeActiveArea(from: newRect, size: size)
            }
            .onEnded { _ in
                dragStartRect = nil
                onDragEnded()
            }
    }
}

extension UIRect {
    func resized(
        from corner: ResizeCorner,
        by translation: CGSize,
        in size: CGSize,
        minSize: CGFloat = 1
    ) -> UIRect {
        let dx = translation.width
        let dy = translation.height

        var new = self

        switch corner {
        case .topLeft:
            new.left = clamp(new.left + dx, min: 0, max: max(0, new.right - minSize))
            new.top = clamp(new.top + dy, min: 0, max: max(0, new.bottom - minSize))

        case .topRight:
            new.right = clamp(
                new.right + dx, min: min(new.left + minSize, size.width), max: size.width)
            new.top = clamp(new.top + dy, min: 0, max: max(0, new.bottom - minSize))

        case .bottomLeft:
            new.left = clamp(new.left + dx, min: 0, max: max(0, new.right - minSize))
            new.bottom = clamp(
                new.bottom + dy, min: min(new.top + minSize, size.height), max: size.height)

        case .bottomRight:
            new.right = clamp(
                new.right + dx, min: min(new.left + minSize, size.width), max: size.width)
            new.bottom = clamp(
                new.bottom + dy, min: min(new.top + minSize, size.height), max: size.height)
        }

        return new
    }
}
