import SwiftUI

struct ActiveAreaOverlay: View {
    @Binding var area: ActiveArea
    let size: CGSize
    let onDragBegan: () -> Void
    let onDragEnded: () -> Void

    @State private var dragStartRect: UIRect?

    private var rect: UIRect {
        makeUIRect(from: area, size: size)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))

            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray, lineWidth: 2)

            selectedRect

            ResizeHandle(
                area: $area,
                corner: .topLeft,
                rect: rect,
                size: size,
                onDragBegan: onDragBegan,
                onDragEnded: onDragEnded
            )
            ResizeHandle(
                area: $area,
                corner: .topRight,
                rect: rect,
                size: size,
                onDragBegan: onDragBegan,
                onDragEnded: onDragEnded
            )
            ResizeHandle(
                area: $area,
                corner: .bottomLeft,
                rect: rect,
                size: size,
                onDragBegan: onDragBegan,
                onDragEnded: onDragEnded
            )
            ResizeHandle(
                area: $area,
                corner: .bottomRight,
                rect: rect,
                size: size,
                onDragBegan: onDragBegan,
                onDragEnded: onDragEnded
            )
        }
    }

    // The active-area outline; drag it to move the whole rectangle.
    private var selectedRect: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(.blue, lineWidth: 3)
            .frame(width: rect.width, height: rect.height)
            .position(rect.center)
            .contentShape(Rectangle())
            .gesture(dragRect)
    }

    private var dragRect: some Gesture {
        DragGesture()
            .onChanged { value in
                if dragStartRect == nil {
                    dragStartRect = rect
                    onDragBegan()
                }
                guard let start = dragStartRect else { return }

                let newRect = start.translated(by: value.translation, in: size)
                area = makeActiveArea(from: newRect, size: size)
            }
            .onEnded { _ in
                dragStartRect = nil
                onDragEnded()
            }
    }
}
